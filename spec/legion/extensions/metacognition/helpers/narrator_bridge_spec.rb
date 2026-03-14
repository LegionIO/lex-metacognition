# frozen_string_literal: true

RSpec.describe Legion::Extensions::Metacognition::Helpers::NarratorBridge do
  let(:model) do
    {
      identity:     { framework: 'LegionIO', role: :cognitive_agent, model: :brain_modeled, extensions: 24 },
      architecture: { total_extensions: 24, loaded_count: 18, unloaded_count: 6, loaded: Array.new(18, :Ext), unloaded: %i[A B C D E F] },
      cognitive:    { mode: :full_active, phases_run: 12, health: 0.92, active_drives: %i[curiosity corrective], attention: { spotlight: 3 },
curiosity: { open_wonders: 4 } },
      capabilities: { perception: { active: true }, cognition: { active: true }, memory: { active: true }, motivation: { active: true },
safety: { active: false } }
    }
  end

  describe '.narrate_self_model' do
    it 'produces a prose string' do
      prose = described_class.narrate_self_model(model)
      expect(prose).to be_a(String)
      expect(prose.length).to be > 50
    end

    it 'includes identity info' do
      prose = described_class.narrate_self_model(model)
      expect(prose).to include('brain_modeled')
      expect(prose).to include('LegionIO')
    end

    it 'includes architecture stats' do
      prose = described_class.narrate_self_model(model)
      expect(prose).to include('18 of 24')
    end

    it 'includes cognitive state' do
      prose = described_class.narrate_self_model(model)
      expect(prose).to include('full_active')
      expect(prose).to include('12 phases')
    end

    it 'includes health label' do
      prose = described_class.narrate_self_model(model)
      expect(prose).to include('excellent')
    end

    it 'includes active drives' do
      prose = described_class.narrate_self_model(model)
      expect(prose).to include('curiosity')
    end
  end

  describe '.narrate_identity' do
    it 'returns nil for non-hash' do
      expect(described_class.narrate_identity(nil)).to be_nil
    end

    it 'describes the agent identity' do
      result = described_class.narrate_identity(model[:identity])
      expect(result).to include('24 extension slots')
    end
  end

  describe '.narrate_architecture' do
    it 'mentions missing extensions' do
      result = described_class.narrate_architecture(model[:architecture])
      expect(result).to include('Missing:')
    end

    it 'omits missing section when all loaded' do
      arch = model[:architecture].merge(unloaded: [])
      result = described_class.narrate_architecture(arch)
      expect(result).not_to include('Missing')
    end
  end

  describe '.narrate_cognitive' do
    it 'returns no tick data message' do
      result = described_class.narrate_cognitive(status: :no_tick_data)
      expect(result).to include('No tick data')
    end

    it 'includes spotlight count' do
      result = described_class.narrate_cognitive(model[:cognitive])
      expect(result).to include('3 signals in spotlight')
    end

    it 'includes open wonders' do
      result = described_class.narrate_cognitive(model[:cognitive])
      expect(result).to include('4 open questions')
    end
  end

  describe '.narrate_capabilities' do
    it 'lists active capability categories' do
      result = described_class.narrate_capabilities(model[:capabilities])
      expect(result).to include('perception')
      expect(result).not_to include('safety')
    end

    it 'returns nil for empty capabilities' do
      expect(described_class.narrate_capabilities({})).to be_nil
    end
  end
end
