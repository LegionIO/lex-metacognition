# frozen_string_literal: true

RSpec.describe Legion::Extensions::Metacognition::Runners::Metacognition do
  let(:store) { Legion::Extensions::Metacognition::Helpers::SnapshotStore.new }
  let(:client) { Legion::Extensions::Metacognition::Client.new(snapshot_store: store) }

  let(:tick_results) do
    {
      sensory_processing:         { spotlight_count: 3, total_signals: 8 },
      emotional_evaluation:       { valence: 0.4, arousal: 0.6 },
      prediction_engine:          { confidence: 0.85, mode: :functional_mapping },
      working_memory_integration: { curiosity_intensity: 0.5, open_wonders: 3 },
      action_selection:           { intentions: [{ drive: :curiosity }, { drive: :epistemic }] },
      post_tick_reflection:       { cognitive_health: 0.88 }
    }
  end

  describe '#introspect' do
    it 'builds and caches a self-model' do
      model = client.introspect(tick_results: tick_results)
      expect(model).to have_key(:identity)
      expect(model).to have_key(:architecture)
      expect(model).to have_key(:cognitive)
      expect(store.size).to eq(1)
    end

    it 'uses cached model when not stale' do
      client.introspect(tick_results: tick_results)
      second = client.introspect(tick_results: {})
      expect(store.size).to eq(1)
      expect(second.dig(:cognitive, :health)).to eq(0.88)
    end

    it 'rebuilds when stale' do
      old = Legion::Extensions::Metacognition::Helpers::SelfModel.build(tick_results: tick_results)
      old[:assembled_at] = Time.now.utc - 60
      store.store(old)

      new_results = tick_results.merge(post_tick_reflection: { cognitive_health: 0.95 })
      model = client.introspect(tick_results: new_results)
      expect(model.dig(:cognitive, :health)).to eq(0.95)
      expect(store.size).to eq(2)
    end
  end

  describe '#self_narrative' do
    it 'returns prose description with model' do
      result = client.self_narrative(tick_results: tick_results)
      expect(result[:prose]).to be_a(String)
      expect(result[:prose].length).to be > 20
      expect(result[:health]).to eq(0.88)
      expect(result).to have_key(:model)
    end
  end

  describe '#explain_subsystem' do
    it 'returns info about a loaded subsystem' do
      client.introspect(tick_results: tick_results)
      result = client.explain_subsystem(subsystem: :metacognition)
      expect(result[:loaded]).to be true
      expect(result[:category]).to eq(:introspection)
    end

    it 'returns info about an unloaded subsystem' do
      result = client.explain_subsystem(subsystem: :memory)
      expect(result[:subsystem]).to eq(:memory)
    end

    it 'returns nil for invalid subsystem' do
      result = client.explain_subsystem(subsystem: :totally_bogus)
      expect(result).to be_nil
    end

    it 'accepts all SUBSYSTEMS entries' do
      Legion::Extensions::Metacognition::Helpers::Constants::SUBSYSTEMS.each do |sub|
        result = client.explain_subsystem(subsystem: sub)
        expect(result).not_to be_nil, "Expected non-nil for subsystem #{sub}"
        expect(result[:subsystem]).to eq(sub)
      end
    end
  end

  describe '#architecture_overview' do
    it 'returns identity and capability info' do
      client.introspect(tick_results: tick_results)
      result = client.architecture_overview
      expect(result[:identity][:framework]).to eq('LegionIO')
      expect(result).to have_key(:capabilities)
    end
  end

  describe '#health_trend' do
    it 'returns trend data' do
      3.times do |i|
        model = Legion::Extensions::Metacognition::Helpers::SelfModel.build(tick_results: tick_results)
        model[:cognitive] = { health: 0.8 + (i * 0.05) }
        model[:assembled_at] = Time.now.utc - (100 - i)
        store.store(model)
      end

      result = client.health_trend
      expect(result).to have_key(:trend)
      expect(result[:snapshots]).to eq(3)
    end
  end

  describe '#architecture_changes' do
    it 'returns change history' do
      result = client.architecture_changes
      expect(result[:changes]).to be_an(Array)
    end
  end

  describe '#metacognition_stats' do
    it 'returns aggregate stats' do
      client.introspect(tick_results: tick_results)
      result = client.metacognition_stats
      expect(result[:snapshots_stored]).to eq(1)
      expect(result[:loaded_extensions]).to be >= 1
      expect(result[:cognitive_health]).to eq(0.88)
    end
  end
end
