# frozen_string_literal: true

module Legion
  module Extensions
    module Metacognition
      module Helpers
        class RegistryStore
          def initialize
            @extensions = {}
            @mutex = Mutex.new
          end

          def register(entry)
            @mutex.synchronize do
              now = Time.now.utc
              defaults = { invocation_count: 0, health_score: 1.0 }
              @extensions[entry[:name]] = defaults.merge(entry).merge(created_at: now, updated_at: now)
            end
          end

          def deregister(name)
            @mutex.synchronize { @extensions.delete(name) }
          end

          def get(name)
            @mutex.synchronize { @extensions[name]&.dup }
          end

          def list(status: nil, category: nil)
            @mutex.synchronize do
              result = @extensions.values
              result = result.select { |e| e[:status] == status.to_s } if status
              result = result.select { |e| e[:category] == category.to_s } if category
              result.map(&:dup)
            end
          end

          def update(name, attrs)
            @mutex.synchronize do
              return nil unless @extensions[name]

              @extensions[name] = @extensions[name].merge(attrs).merge(updated_at: Time.now.utc)
              @extensions[name].dup
            end
          end

          def category_distribution
            @mutex.synchronize do
              @extensions.values.group_by { |e| e[:category] }.transform_values(&:count)
            end
          end

          def count
            @mutex.synchronize { @extensions.size }
          end

          def by_health(threshold: 0.4)
            @mutex.synchronize do
              @extensions.values.select { |e| e[:health_score] && e[:health_score] < threshold }.map(&:dup)
            end
          end
        end
      end
    end
  end
end
