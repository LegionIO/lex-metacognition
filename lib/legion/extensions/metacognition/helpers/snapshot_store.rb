# frozen_string_literal: true

module Legion
  module Extensions
    module Metacognition
      module Helpers
        class SnapshotStore
          attr_reader :snapshots

          def initialize
            @snapshots = []
          end

          def store(model)
            @snapshots << model
            @snapshots = @snapshots.last(Constants::MAX_SNAPSHOTS) if @snapshots.size > Constants::MAX_SNAPSHOTS
            model
          end

          def latest
            @snapshots.last
          end

          def stale?
            return true if @snapshots.empty?

            age = Time.now.utc - (latest[:assembled_at] || Time.at(0))
            age > Constants::SNAPSHOT_TTL
          end

          def history(limit: 10)
            @snapshots.last(limit)
          end

          def architecture_changes
            return [] if @snapshots.size < 2

            changes = []
            @snapshots.each_cons(2) do |prev, curr|
              prev_loaded = prev.dig(:architecture, :loaded) || []
              curr_loaded = curr.dig(:architecture, :loaded) || []

              added = curr_loaded - prev_loaded
              removed = prev_loaded - curr_loaded

              next if added.empty? && removed.empty?

              changes << {
                at:      curr[:assembled_at],
                added:   added,
                removed: removed
              }
            end
            changes
          end

          def health_trend(limit: 20)
            recent = @snapshots.last(limit)
            recent.filter_map do |s|
              health = s.dig(:cognitive, :health)
              next unless health

              { at: s[:assembled_at], health: health }
            end
          end

          def size
            @snapshots.size
          end

          def clear
            @snapshots.clear
          end
        end
      end
    end
  end
end
