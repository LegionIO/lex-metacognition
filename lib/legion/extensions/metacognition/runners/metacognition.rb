# frozen_string_literal: true

module Legion
  module Extensions
    module Metacognition
      module Runners
        module Metacognition
          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)

          def introspect(tick_results: {}, subsystem_states: {}, **)
            model = if snapshot_store.stale?
                      fresh = Helpers::SelfModel.build(
                        subsystem_states: subsystem_states,
                        tick_results:     tick_results
                      )
                      snapshot_store.store(fresh)
                      fresh
                    else
                      snapshot_store.latest
                    end

            Legion::Logging.debug "[metacognition] introspect: #{model.dig(:architecture, :loaded_count)} extensions loaded"
            model
          end

          def self_narrative(tick_results: {}, subsystem_states: {}, **)
            model = introspect(tick_results: tick_results, subsystem_states: subsystem_states)
            prose = Helpers::NarratorBridge.narrate_self_model(model)

            {
              prose:     prose,
              health:    model.dig(:cognitive, :health),
              mode:      model.dig(:cognitive, :mode),
              model:     model,
              timestamp: Time.now.utc
            }
          end

          def explain_subsystem(subsystem:, **)
            sym = subsystem.to_sym
            ext_sym = sym.to_s.split('_').map(&:capitalize).join.to_sym

            loaded = begin
              Legion::Extensions.const_defined?(ext_sym)
            rescue StandardError
              false
            end
            category = Helpers::Constants::EXTENSION_CAPABILITIES[ext_sym] || :unknown

            latest = snapshot_store.latest
            state = latest&.dig(:subsystems, sym)

            {
              subsystem: sym,
              extension: ext_sym,
              loaded:    loaded,
              category:  category,
              state:     state || { status: :no_data }
            }
          end

          def architecture_overview(**)
            model = snapshot_store.latest || Helpers::SelfModel.build
            snapshot_store.store(model) if snapshot_store.stale?

            {
              identity:     model[:identity],
              architecture: model[:architecture],
              capabilities: model[:capabilities],
              assembled_at: model[:assembled_at]
            }
          end

          def health_trend(limit: 20, **)
            {
              trend:     snapshot_store.health_trend(limit: limit),
              snapshots: snapshot_store.size,
              current:   snapshot_store.latest&.dig(:cognitive, :health)
            }
          end

          def architecture_changes(**)
            {
              changes:   snapshot_store.architecture_changes,
              snapshots: snapshot_store.size
            }
          end

          def metacognition_stats(**)
            {
              snapshots_stored:   snapshot_store.size,
              latest_stale:       snapshot_store.stale?,
              loaded_extensions:  snapshot_store.latest&.dig(:architecture, :loaded_count) || 0,
              cognitive_health:   snapshot_store.latest&.dig(:cognitive, :health),
              capability_summary: capability_summary
            }
          end

          private

          def snapshot_store
            @snapshot_store ||= Helpers::SnapshotStore.new
          end

          def capability_summary
            latest = snapshot_store.latest
            return {} unless latest&.dig(:capabilities)

            latest[:capabilities].transform_values { |v| v[:active] }
          end
        end
      end
    end
  end
end
