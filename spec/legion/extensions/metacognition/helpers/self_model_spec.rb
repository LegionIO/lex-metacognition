# frozen_string_literal: true

RSpec.describe Legion::Extensions::Metacognition::Helpers::SelfModel do
  describe '.build' do
    it 'returns a structured self-model' do
      model = described_class.build
      expect(model).to have_key(:identity)
      expect(model).to have_key(:architecture)
      expect(model).to have_key(:capabilities)
      expect(model).to have_key(:subsystems)
      expect(model).to have_key(:cognitive)
      expect(model).to have_key(:assembled_at)
    end

    it 'includes identity information' do
      model = described_class.build
      expect(model[:identity][:framework]).to eq('LegionIO')
      expect(model[:identity][:role]).to eq(:cognitive_agent)
      expect(model[:identity][:model]).to eq(:brain_modeled)
    end

    it 'discovers Metacognition as loaded' do
      model = described_class.build
      expect(model[:architecture][:loaded]).to include(:Metacognition)
    end

    it 'includes cognitive snapshot from tick_results' do
      tick_results = {
        post_tick_reflection: { cognitive_health: 0.85 },
        action_selection:     { intentions: [{ drive: :curiosity }] }
      }
      model = described_class.build(tick_results: tick_results)
      expect(model[:cognitive][:health]).to eq(0.85)
      expect(model[:cognitive][:active_drives]).to eq([:curiosity])
    end

    it 'returns no_tick_data for empty tick_results' do
      model = described_class.build(tick_results: {})
      expect(model[:cognitive][:status]).to eq(:no_tick_data)
    end
  end

  describe '.discover_loaded_extensions' do
    it 'returns hash of extension availability' do
      result = described_class.discover_loaded_extensions
      expect(result).to be_a(Hash)
      expect(result[:Metacognition][:loaded]).to be true
    end
  end

  describe '.map_capabilities' do
    it 'groups loaded extensions by category' do
      loaded = { Metacognition: { loaded: true }, Memory: { loaded: false } }
      caps = described_class.map_capabilities(loaded)
      expect(caps[:introspection][:active]).to be true
      expect(caps[:memory][:active]).to be false
    end

    it 'lists extensions per category' do
      loaded = { Metacognition: { loaded: true }, Reflection: { loaded: true } }
      caps = described_class.map_capabilities(loaded)
      expect(caps[:introspection][:extensions]).to include(:Metacognition, :Reflection)
    end
  end

  describe '.build_cognitive_snapshot' do
    it 'extracts attention data' do
      tick_results = {
        sensory_processing: { spotlight_count: 3, total_signals: 10 }
      }
      snapshot = described_class.build_cognitive_snapshot(tick_results)
      expect(snapshot[:attention]).to eq(spotlight: 3, total: 10)
    end

    it 'extracts curiosity data' do
      tick_results = {
        working_memory_integration: { curiosity_intensity: 0.7, open_wonders: 4 }
      }
      snapshot = described_class.build_cognitive_snapshot(tick_results)
      expect(snapshot[:curiosity]).to eq(intensity: 0.7, open_wonders: 4)
    end

    it 'extracts prediction data' do
      tick_results = {
        prediction_engine: { confidence: 0.9, mode: :functional_mapping }
      }
      snapshot = described_class.build_cognitive_snapshot(tick_results)
      expect(snapshot[:prediction]).to eq(confidence: 0.9, mode: :functional_mapping)
    end
  end

  describe '.health_label' do
    it 'returns :excellent for >= 0.8' do
      expect(described_class.health_label(0.92)).to eq(:excellent)
    end

    it 'returns :good for 0.6-0.8' do
      expect(described_class.health_label(0.7)).to eq(:good)
    end

    it 'returns :fair for 0.4-0.6' do
      expect(described_class.health_label(0.5)).to eq(:fair)
    end

    it 'returns :degraded for 0.2-0.4' do
      expect(described_class.health_label(0.3)).to eq(:degraded)
    end

    it 'returns :critical for < 0.2' do
      expect(described_class.health_label(0.1)).to eq(:critical)
    end

    it 'returns :unknown for nil' do
      expect(described_class.health_label(nil)).to eq(:unknown)
    end
  end
end
