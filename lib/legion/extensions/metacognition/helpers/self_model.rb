# frozen_string_literal: true

module Legion
  module Extensions
    module Metacognition
      module Helpers
        module SelfModel
          module_function

          def build(subsystem_states: {}, tick_results: {})
            loaded = discover_loaded_extensions
            capabilities = map_capabilities(loaded)

            {
              identity:     build_identity,
              architecture: build_architecture(loaded),
              capabilities: capabilities,
              subsystems:   build_subsystem_states(subsystem_states),
              cognitive:    build_cognitive_snapshot(tick_results),
              assembled_at: Time.now.utc
            }
          end

          def discover_loaded_extensions
            Constants::EXTENSION_CAPABILITIES.each_with_object({}) do |(ext_sym, _cat), acc|
              loaded = Legion::Extensions.const_defined?(ext_sym)
              acc[ext_sym] = { loaded: loaded }
            end
          rescue StandardError
            {}
          end

          def map_capabilities(loaded_map)
            active = loaded_map.select { |_, v| v[:loaded] }
            grouped = active.keys.group_by { |ext| Constants::EXTENSION_CAPABILITIES[ext] || :unknown }

            Constants::CAPABILITY_CATEGORIES.to_h do |cat|
              extensions = grouped[cat] || []
              [cat, { active: extensions.size.positive?, extensions: extensions }]
            end
          end

          def build_identity
            {
              framework:  'LegionIO',
              role:       :cognitive_agent,
              model:      :brain_modeled,
              extensions: Constants::EXTENSION_CAPABILITIES.size
            }
          end

          def build_architecture(loaded_map)
            total = loaded_map.size
            active = loaded_map.count { |_, v| v[:loaded] }

            {
              total_extensions: total,
              loaded_count:     active,
              unloaded_count:   total - active,
              loaded:           loaded_map.select { |_, v| v[:loaded] }.keys,
              unloaded:         loaded_map.reject { |_, v| v[:loaded] }.keys
            }
          end

          def build_subsystem_states(states)
            return {} unless states.is_a?(Hash)

            states.each_with_object({}) do |(key, state), acc|
              acc[key] = normalize_subsystem_state(state)
            end
          end

          def normalize_subsystem_state(state)
            return { status: :unknown } unless state.is_a?(Hash)

            state.slice(:health, :status, :mode, :count, :active_count, :score)
          end

          def build_cognitive_snapshot(tick_results)
            return { status: :no_tick_data } unless tick_results.is_a?(Hash) && !tick_results.empty?

            {
              mode:           extract_mode(tick_results),
              phases_run:     tick_results.keys.size,
              has_reflection: tick_results.key?(:post_tick_reflection),
              health:         extract_health(tick_results),
              active_drives:  extract_drives(tick_results),
              attention:      extract_attention(tick_results),
              curiosity:      extract_curiosity(tick_results),
              prediction:     extract_prediction(tick_results)
            }
          end

          def extract_mode(tick_results)
            tick_results.dig(:tick_meta, :mode) || :unknown
          end

          def extract_health(tick_results)
            reflection = tick_results[:post_tick_reflection]
            return nil unless reflection.is_a?(Hash)

            reflection[:cognitive_health]
          end

          def extract_drives(tick_results)
            volition = tick_results[:action_selection]
            return [] unless volition.is_a?(Hash) && volition[:intentions].is_a?(Array)

            volition[:intentions].first(3).map { |i| i[:drive] }.compact
          end

          def extract_attention(tick_results)
            attention = tick_results[:sensory_processing]
            return nil unless attention.is_a?(Hash)

            { spotlight: attention[:spotlight_count], total: attention[:total_signals] }
          end

          def extract_curiosity(tick_results)
            curiosity = tick_results[:working_memory_integration]
            return nil unless curiosity.is_a?(Hash)

            { intensity: curiosity[:curiosity_intensity], open_wonders: curiosity[:open_wonders] }
          end

          def extract_prediction(tick_results)
            prediction = tick_results[:prediction_engine]
            return nil unless prediction.is_a?(Hash)

            { confidence: prediction[:confidence], mode: prediction[:mode] }
          end

          def health_label(score)
            return :unknown unless score.is_a?(Numeric)

            Constants::HEALTH_LABELS.each do |range, label|
              return label if range.include?(score)
            end
            :unknown
          end
        end
      end
    end
  end
end
