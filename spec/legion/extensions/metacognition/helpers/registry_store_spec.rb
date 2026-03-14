# frozen_string_literal: true

RSpec.describe Legion::Extensions::Metacognition::Helpers::RegistryStore do
  subject(:store) { described_class.new }

  let(:entry) do
    {
      name:         'lex-memory',
      module_name:  'Memory',
      category:     'memory',
      status:       'active',
      health_score: 1.0
    }
  end

  let(:entry2) do
    {
      name:         'lex-emotion',
      module_name:  'Emotion',
      category:     'perception',
      status:       'active',
      health_score: 0.9
    }
  end

  describe '#register' do
    it 'stores an entry by name' do
      store.register(entry)
      expect(store.count).to eq(1)
    end

    it 'sets created_at and updated_at on register' do
      store.register(entry)
      result = store.get('lex-memory')
      expect(result[:created_at]).to be_a(Time)
      expect(result[:updated_at]).to be_a(Time)
    end

    it 'sets invocation_count to 0 on register' do
      store.register(entry)
      expect(store.get('lex-memory')[:invocation_count]).to eq(0)
    end

    it 'sets health_score to 1.0 on register' do
      entry_no_health = entry.except(:health_score)
      store.register(entry_no_health)
      expect(store.get('lex-memory')[:health_score]).to eq(1.0)
    end

    it 'overwrites an existing entry with the same name' do
      store.register(entry)
      store.register(entry.merge(category: 'cognition'))
      expect(store.get('lex-memory')[:category]).to eq('cognition')
      expect(store.count).to eq(1)
    end
  end

  describe '#deregister' do
    it 'removes an entry by name' do
      store.register(entry)
      store.deregister('lex-memory')
      expect(store.count).to eq(0)
    end

    it 'returns nil when deregistering a non-existent name' do
      expect(store.deregister('lex-nonexistent')).to be_nil
    end
  end

  describe '#get' do
    it 'returns nil for unknown name' do
      expect(store.get('lex-unknown')).to be_nil
    end

    it 'returns a copy of the entry' do
      store.register(entry)
      result = store.get('lex-memory')
      expect(result[:name]).to eq('lex-memory')
    end

    it 'returns a dup (not the same object)' do
      store.register(entry)
      result1 = store.get('lex-memory')
      result2 = store.get('lex-memory')
      expect(result1).not_to be(result2)
    end
  end

  describe '#list' do
    before do
      store.register(entry)
      store.register(entry2)
      store.register(entry.merge(name: 'lex-episodic', category: 'memory', status: 'inactive'))
    end

    it 'returns all entries with no filters' do
      expect(store.list.size).to eq(3)
    end

    it 'filters by status' do
      active = store.list(status: 'active')
      expect(active.size).to eq(2)
      expect(active.map { |e| e[:status] }.uniq).to eq(['active'])
    end

    it 'filters by category' do
      memory = store.list(category: 'memory')
      expect(memory.size).to eq(2)
    end

    it 'filters by both status and category' do
      result = store.list(status: 'active', category: 'memory')
      expect(result.size).to eq(1)
      expect(result.first[:name]).to eq('lex-memory')
    end

    it 'returns empty array when no match' do
      expect(store.list(category: 'nonexistent')).to eq([])
    end
  end

  describe '#update' do
    it 'returns nil for unknown name' do
      expect(store.update('lex-missing', { health_score: 0.5 })).to be_nil
    end

    it 'updates the specified attributes' do
      store.register(entry)
      result = store.update('lex-memory', { health_score: 0.75, status: 'degraded' })
      expect(result[:health_score]).to eq(0.75)
      expect(result[:status]).to eq('degraded')
    end

    it 'updates updated_at on modification' do
      store.register(entry)
      original_time = store.get('lex-memory')[:updated_at]
      result = store.update('lex-memory', { health_score: 0.5 })
      expect(result[:updated_at]).to be >= original_time
    end

    it 'preserves unchanged attributes' do
      store.register(entry)
      store.update('lex-memory', { health_score: 0.5 })
      expect(store.get('lex-memory')[:module_name]).to eq('Memory')
    end
  end

  describe '#category_distribution' do
    it 'returns empty hash when no entries' do
      expect(store.category_distribution).to eq({})
    end

    it 'counts entries per category' do
      store.register(entry)
      store.register(entry2)
      store.register(entry.merge(name: 'lex-episodic', category: 'memory'))
      dist = store.category_distribution
      expect(dist['memory']).to eq(2)
      expect(dist['perception']).to eq(1)
    end
  end

  describe '#count' do
    it 'returns 0 when empty' do
      expect(store.count).to eq(0)
    end

    it 'returns the number of registered entries' do
      store.register(entry)
      store.register(entry2)
      expect(store.count).to eq(2)
    end
  end

  describe '#by_health' do
    before do
      store.register(entry.merge(health_score: 0.9))
      store.register(entry2.merge(health_score: 0.3))
      store.register(entry.merge(name: 'lex-prediction', module_name: 'Prediction', category: 'cognition', health_score: 0.1))
    end

    it 'returns entries below default threshold of 0.4' do
      result = store.by_health
      expect(result.size).to eq(2)
      result.each { |e| expect(e[:health_score]).to be < 0.4 }
    end

    it 'accepts a custom threshold' do
      result = store.by_health(threshold: 0.2)
      expect(result.size).to eq(1)
      expect(result.first[:health_score]).to eq(0.1)
    end

    it 'returns empty array when all entries are healthy' do
      healthy_store = described_class.new
      healthy_store.register(entry.merge(health_score: 0.95))
      expect(healthy_store.by_health).to eq([])
    end
  end

  describe 'thread safety' do
    it 'handles concurrent registrations without data corruption' do
      threads = 20.times.map do |i|
        Thread.new do
          store.register(entry.merge(name: "lex-thread-#{i}", module_name: "Mod#{i}"))
        end
      end
      threads.each(&:join)
      expect(store.count).to eq(20)
    end

    it 'handles concurrent reads and writes safely' do
      store.register(entry)
      errors = []
      threads = 10.times.map do
        Thread.new do
          store.get('lex-memory')
          store.update('lex-memory', { health_score: rand })
        rescue StandardError => e
          errors << e
        end
      end
      threads.each(&:join)
      expect(errors).to be_empty
    end
  end
end
