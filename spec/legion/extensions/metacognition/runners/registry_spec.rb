# frozen_string_literal: true

RSpec.describe Legion::Extensions::Metacognition::Runners::Registry do
  subject(:runner) { described_class }

  # Reset in-memory store between examples
  before { runner.instance_variable_set(:@store, nil) }

  let(:base_args) do
    {
      name:        'lex-memory',
      module_name: 'Memory',
      category:    'memory'
    }
  end

  describe '#register_extension' do
    it 'returns success: true with name and category' do
      result = runner.register_extension(**base_args)
      expect(result[:success]).to be true
      expect(result[:name]).to eq('lex-memory')
      expect(result[:category]).to eq('memory')
    end

    it 'stores the extension in-memory' do
      runner.register_extension(**base_args)
      status = runner.extension_status(name: 'lex-memory')
      expect(status[:success]).to be true
      expect(status[:extension][:module_name]).to eq('Memory')
    end

    it 'accepts optional description and cognitive_concept' do
      runner.register_extension(
        **base_args,
        description:       'Trace-based episodic memory',
        cognitive_concept: 'Hebbian learning'
      )
      ext = runner.extension_status(name: 'lex-memory')[:extension]
      expect(ext[:description]).to eq('Trace-based episodic memory')
      expect(ext[:cognitive_concept]).to eq('Hebbian learning')
    end

    it 'coerces category to string' do
      runner.register_extension(**base_args, category: :perception)
      ext = runner.extension_status(name: 'lex-memory')[:extension]
      expect(ext[:category]).to eq('perception')
    end

    it 'defaults category to cognition when not provided' do
      result = runner.register_extension(name: 'lex-tick', module_name: 'Tick')
      expect(result[:category]).to eq('cognition')
    end

    it 'accepts spec_count and spec_pass_count' do
      runner.register_extension(**base_args, spec_count: 42, spec_pass_count: 40)
      ext = runner.extension_status(name: 'lex-memory')[:extension]
      expect(ext[:spec_count]).to eq(42)
      expect(ext[:spec_pass_count]).to eq(40)
    end

    it 'accepts build_batch' do
      runner.register_extension(**base_args, build_batch: 3)
      ext = runner.extension_status(name: 'lex-memory')[:extension]
      expect(ext[:build_batch]).to eq(3)
    end

    it 'ignores extra keyword arguments via **' do
      expect { runner.register_extension(**base_args, unknown_key: 'ignored') }.not_to raise_error
    end
  end

  describe '#deregister_extension' do
    before { runner.register_extension(**base_args) }

    it 'returns success: true' do
      result = runner.deregister_extension(name: 'lex-memory')
      expect(result[:success]).to be true
      expect(result[:name]).to eq('lex-memory')
    end

    it 'removes the extension from the store' do
      runner.deregister_extension(name: 'lex-memory')
      status = runner.extension_status(name: 'lex-memory')
      expect(status[:success]).to be false
      expect(status[:error]).to eq(:not_found)
    end
  end

  describe '#list_extensions' do
    before do
      runner.register_extension(name: 'lex-memory',    module_name: 'Memory',    category: 'memory')
      runner.register_extension(name: 'lex-emotion',   module_name: 'Emotion',   category: 'perception')
      runner.register_extension(name: 'lex-tick',      module_name: 'Tick',      category: 'cognition')
    end

    it 'returns all extensions with no filter' do
      result = runner.list_extensions
      expect(result[:success]).to be true
      expect(result[:count]).to eq(3)
      expect(result[:extensions].size).to eq(3)
    end

    it 'filters by category' do
      result = runner.list_extensions(category: 'memory')
      expect(result[:count]).to eq(1)
      expect(result[:extensions].first[:name]).to eq('lex-memory')
    end

    it 'filters by status' do
      runner.update_extension(name: 'lex-tick', attrs: { status: 'inactive' })
      result = runner.list_extensions(status: 'inactive')
      expect(result[:count]).to eq(1)
      expect(result[:extensions].first[:name]).to eq('lex-tick')
    end

    it 'returns empty list when no match' do
      result = runner.list_extensions(category: 'nonexistent')
      expect(result[:success]).to be true
      expect(result[:count]).to eq(0)
    end
  end

  describe '#extension_status' do
    it 'returns not_found for unknown extension' do
      result = runner.extension_status(name: 'lex-unknown')
      expect(result[:success]).to be false
      expect(result[:error]).to eq(:not_found)
    end

    it 'returns the extension data for a known extension' do
      runner.register_extension(**base_args)
      result = runner.extension_status(name: 'lex-memory')
      expect(result[:success]).to be true
      expect(result[:extension][:name]).to eq('lex-memory')
    end
  end

  describe '#update_extension' do
    before { runner.register_extension(**base_args) }

    it 'returns success: true and updated data' do
      result = runner.update_extension(name: 'lex-memory', attrs: { health_score: 0.6 })
      expect(result[:success]).to be true
      expect(result[:extension][:health_score]).to eq(0.6)
    end

    it 'returns not_found for unknown extension' do
      result = runner.update_extension(name: 'lex-missing', attrs: { health_score: 0.5 })
      expect(result[:success]).to be false
      expect(result[:error]).to eq(:not_found)
    end

    it 'updates status' do
      runner.update_extension(name: 'lex-memory', attrs: { status: 'degraded' })
      ext = runner.extension_status(name: 'lex-memory')[:extension]
      expect(ext[:status]).to eq('degraded')
    end
  end

  describe '#category_distribution' do
    before do
      runner.register_extension(name: 'lex-memory',    module_name: 'Memory',    category: 'memory')
      runner.register_extension(name: 'lex-emotion',   module_name: 'Emotion',   category: 'perception')
      runner.register_extension(name: 'lex-tick',      module_name: 'Tick',      category: 'cognition')
      runner.register_extension(name: 'lex-cortex',    module_name: 'Cortex',    category: 'cognition')
    end

    it 'returns success: true' do
      expect(runner.category_distribution[:success]).to be true
    end

    it 'returns distribution counts' do
      dist = runner.category_distribution[:distribution]
      expect(dist['cognition']).to eq(2)
      expect(dist['memory']).to eq(1)
      expect(dist['perception']).to eq(1)
    end

    it 'returns percentage breakdown' do
      percentages = runner.category_distribution[:percentages]
      expect(percentages['cognition']).to eq(50.0)
    end

    it 'returns total count' do
      expect(runner.category_distribution[:total]).to eq(4)
    end

    it 'returns zero percentages when store is empty' do
      runner.instance_variable_set(:@store, nil)
      result = runner.category_distribution
      expect(result[:total]).to eq(0)
      expect(result[:distribution]).to eq({})
    end
  end

  describe '#degraded_extensions' do
    before do
      runner.register_extension(**base_args)
      runner.update_extension(name: 'lex-memory', attrs: { health_score: 0.9 })
      runner.register_extension(name: 'lex-emotion', module_name: 'Emotion', category: 'perception')
      runner.update_extension(name: 'lex-emotion', attrs: { health_score: 0.2 })
      runner.register_extension(name: 'lex-tick', module_name: 'Tick', category: 'cognition')
      runner.update_extension(name: 'lex-tick', attrs: { health_score: 0.05 })
    end

    it 'returns success: true' do
      expect(runner.degraded_extensions[:success]).to be true
    end

    it 'returns extensions below default threshold (0.4)' do
      result = runner.degraded_extensions
      expect(result[:count]).to eq(2)
      result[:extensions].each { |e| expect(e[:health_score]).to be < 0.4 }
    end

    it 'accepts a custom threshold' do
      result = runner.degraded_extensions(threshold: 0.1)
      expect(result[:count]).to eq(1)
    end

    it 'returns empty list when all are healthy' do
      runner.update_extension(name: 'lex-emotion', attrs: { health_score: 0.95 })
      runner.update_extension(name: 'lex-tick',    attrs: { health_score: 0.85 })
      result = runner.degraded_extensions
      expect(result[:count]).to eq(0)
    end
  end

  describe '#seed_from_constants' do
    let(:mock_capabilities) do
      {
        Memory:  :memory,
        Emotion: :perception,
        Tick:    :cognition
      }
    end

    before do
      stub_const(
        'Legion::Extensions::Metacognition::Helpers::Constants::EXTENSION_CAPABILITIES',
        mock_capabilities
      )
    end

    it 'returns success: true' do
      expect(runner.seed_from_constants[:success]).to be true
    end

    it 'seeds entries for all capabilities' do
      result = runner.seed_from_constants
      expect(result[:seeded]).to eq(3)
      expect(result[:total]).to eq(3)
    end

    it 'skips already-registered extensions' do
      runner.register_extension(name: 'lex-memory', module_name: 'Memory', category: 'memory')
      result = runner.seed_from_constants
      expect(result[:seeded]).to eq(2)
    end

    it 'seeds with correct lex name derived from module name' do
      runner.seed_from_constants
      expect(runner.extension_status(name: 'lex-memory')[:success]).to be true
      expect(runner.extension_status(name: 'lex-emotion')[:success]).to be true
      expect(runner.extension_status(name: 'lex-tick')[:success]).to be true
    end

    it 'seeds with correct category from capabilities map' do
      runner.seed_from_constants
      expect(runner.extension_status(name: 'lex-memory')[:extension][:category]).to eq('memory')
      expect(runner.extension_status(name: 'lex-emotion')[:extension][:category]).to eq('perception')
    end

    it 'is idempotent — running twice does not duplicate entries' do
      runner.seed_from_constants
      result = runner.seed_from_constants
      expect(result[:seeded]).to eq(0)
      expect(runner.list_extensions[:count]).to eq(3)
    end
  end
end
