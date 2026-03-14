# frozen_string_literal: true

module Legion
  module Extensions
    module Metacognition
      module Helpers
        module NarratorBridge
          module_function

          def narrate_self_model(model)
            parts = []
            parts << narrate_identity(model[:identity])
            parts << narrate_architecture(model[:architecture])
            parts << narrate_cognitive(model[:cognitive])
            parts << narrate_capabilities(model[:capabilities])
            parts.compact.join(' ')
          end

          def narrate_identity(identity)
            return nil unless identity.is_a?(Hash)

            "I am a #{identity[:model]} #{identity[:role]} built on #{identity[:framework]} " \
              "with #{identity[:extensions]} extension slots."
          end

          def narrate_architecture(arch)
            return nil unless arch.is_a?(Hash)

            loaded = arch[:loaded_count] || 0
            total = arch[:total_extensions] || 0
            unloaded = arch[:unloaded] || []

            base = "#{loaded} of #{total} extensions are active."
            if unloaded.empty?
              base
            else
              "#{base} Missing: #{unloaded.first(3).join(', ')}#{'...' if unloaded.size > 3}."
            end
          end

          def narrate_cognitive(cognitive)
            return nil unless cognitive.is_a?(Hash)
            return 'No tick data available.' if cognitive[:status] == :no_tick_data

            parts = []
            parts << "Operating in #{cognitive[:mode]} mode." if cognitive[:mode] && cognitive[:mode] != :unknown
            parts << "Running #{cognitive[:phases_run]} phases per tick." if cognitive[:phases_run]

            if cognitive[:health]
              label = SelfModel.health_label(cognitive[:health])
              parts << "Cognitive health: #{label} (#{(cognitive[:health] * 100).round}%)."
            end

            parts << "Active drives: #{cognitive[:active_drives].join(', ')}." if cognitive[:active_drives]&.any?

            if cognitive[:attention]
              att = cognitive[:attention]
              parts << "#{att[:spotlight] || 0} signals in spotlight focus." if att[:spotlight]
            end

            if cognitive[:curiosity]
              cur = cognitive[:curiosity]
              parts << "#{cur[:open_wonders] || 0} open questions." if cur[:open_wonders]
            end

            parts.join(' ')
          end

          def narrate_capabilities(capabilities)
            return nil unless capabilities.is_a?(Hash)

            active_cats = capabilities.select { |_, v| v[:active] }.keys
            return nil if active_cats.empty?

            "Active capabilities: #{active_cats.join(', ')}."
          end
        end
      end
    end
  end
end
