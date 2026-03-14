# frozen_string_literal: true

module Legion
  module Extensions
    module Metacognition
      module Runners
        module Registry
          extend self

          def register_extension(name:, module_name:, category: 'cognition', **)
            entry = build_entry(name: name, module_name: module_name, category: category, **)

            if db_available?
              db_register(entry)
            else
              store.register(entry)
            end

            Legion::Logging.info "[metacognition:registry] registered #{name} (#{category})" if defined?(Legion::Logging)
            { success: true, name: name, category: category }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def deregister_extension(name:, **)
            if db_available?
              db_deregister(name)
            else
              store.deregister(name)
            end
            { success: true, name: name }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def list_extensions(status: nil, category: nil, **)
            extensions = if db_available?
                           db_list(status: status, category: category)
                         else
                           store.list(status: status, category: category)
                         end
            { success: true, extensions: extensions, count: extensions.size }
          end

          def extension_status(name:, **)
            ext = if db_available?
                    db_get(name)
                  else
                    store.get(name)
                  end
            return { success: false, error: :not_found } unless ext

            { success: true, extension: ext }
          end

          def update_extension(name:, attrs: {}, **)
            result = if db_available?
                       db_update(name, attrs)
                     else
                       store.update(name, attrs)
                     end
            return { success: false, error: :not_found } unless result

            { success: true, extension: result }
          end

          def category_distribution(**)
            dist = if db_available?
                     db_category_distribution
                   else
                     store.category_distribution
                   end

            total = dist.values.sum
            percentages = dist.transform_values { |v| total.positive? ? (v.to_f / total * 100).round(1) : 0.0 }

            { success: true, distribution: dist, percentages: percentages, total: total }
          end

          def degraded_extensions(threshold: 0.4, **)
            extensions = if db_available?
                           db_by_health(threshold)
                         else
                           store.by_health(threshold: threshold)
                         end
            { success: true, extensions: extensions, count: extensions.size }
          end

          def seed_from_constants(**)
            capabilities = Helpers::Constants::EXTENSION_CAPABILITIES
            seeded = 0

            capabilities.each do |mod_name, category|
              snake = mod_name.to_s.gsub(/([A-Z])/, '_\1').sub(/^_/, '').downcase
              lex_name = "lex-#{snake.tr('_', '-')}"
              next if extension_status(name: lex_name)[:success]

              register_extension(
                name:        lex_name,
                module_name: mod_name.to_s,
                category:    category.to_s
              )
              seeded += 1
            end

            { success: true, seeded: seeded, total: capabilities.size }
          end

          private

          def build_entry(name:, module_name:, category:, **opts)
            {
              name:                 name,
              module_name:          module_name,
              category:             category.to_s,
              description:          opts[:description],
              cognitive_concept:    opts[:cognitive_concept],
              metaphor_description: opts[:metaphor_description],
              build_batch:          opts[:build_batch],
              build_date:           Time.now.utc,
              status:               'active',
              spec_count:           opts.fetch(:spec_count, 0),
              spec_pass_count:      opts.fetch(:spec_pass_count, 0)
            }
          end

          def store
            @store ||= Helpers::RegistryStore.new
          end

          def db_available?
            defined?(Legion::Data) && Legion::Data.respond_to?(:connection) && Legion::Data.connection
          rescue StandardError
            false
          end

          def db_table
            Legion::Data.connection[:extensions_registry]
          end

          def db_register(entry)
            db_table.insert(entry.merge(created_at: Time.now.utc, updated_at: Time.now.utc))
          end

          def db_deregister(name)
            db_table.where(name: name).delete
          end

          def db_get(name)
            db_table.where(name: name).first
          end

          def db_list(status: nil, category: nil)
            ds = db_table
            ds = ds.where(status: status.to_s) if status
            ds = ds.where(category: category.to_s) if category
            ds.all
          end

          def db_update(name, attrs)
            db_table.where(name: name).update(attrs.merge(updated_at: Time.now.utc))
            db_get(name)
          end

          def db_category_distribution
            db_table.group_and_count(:category).all.to_h { |r| [r[:category], r[:count]] }
          end

          def db_by_health(threshold)
            db_table.where { health_score < threshold }.all
          end
        end
      end
    end
  end
end
