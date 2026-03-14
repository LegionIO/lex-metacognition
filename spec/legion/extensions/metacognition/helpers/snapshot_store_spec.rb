# frozen_string_literal: true

RSpec.describe Legion::Extensions::Metacognition::Helpers::SnapshotStore do
  subject(:store) { described_class.new }

  let(:model) do
    {
      identity:     { framework: 'LegionIO' },
      architecture: { loaded: %i[Tick Memory], loaded_count: 2, total_extensions: 5, unloaded: %i[Emotion Prediction Cortex] },
      capabilities: {},
      subsystems:   {},
      cognitive:    { health: 0.85, mode: :full_active },
      assembled_at: Time.now.utc
    }
  end

  describe '#store' do
    it 'adds a model snapshot' do
      store.store(model)
      expect(store.size).to eq(1)
    end

    it 'caps at MAX_SNAPSHOTS' do
      55.times { |i| store.store(model.merge(assembled_at: Time.now.utc + i)) }
      expect(store.size).to eq(50)
    end
  end

  describe '#latest' do
    it 'returns nil when empty' do
      expect(store.latest).to be_nil
    end

    it 'returns the most recent snapshot' do
      store.store(model)
      expect(store.latest[:identity][:framework]).to eq('LegionIO')
    end
  end

  describe '#stale?' do
    it 'returns true when empty' do
      expect(store.stale?).to be true
    end

    it 'returns false for fresh snapshot' do
      store.store(model)
      expect(store.stale?).to be false
    end

    it 'returns true for old snapshot' do
      old = model.merge(assembled_at: Time.now.utc - 60)
      store.store(old)
      expect(store.stale?).to be true
    end
  end

  describe '#history' do
    it 'returns limited history' do
      5.times { |i| store.store(model.merge(assembled_at: Time.now.utc + i)) }
      expect(store.history(limit: 3).size).to eq(3)
    end
  end

  describe '#architecture_changes' do
    it 'returns empty array with fewer than 2 snapshots' do
      store.store(model)
      expect(store.architecture_changes).to eq([])
    end

    it 'detects added extensions' do
      store.store(model)
      updated = model.merge(
        architecture: { loaded: %i[Tick Memory Emotion], loaded_count: 3, total_extensions: 5, unloaded: %i[Prediction Cortex] },
        assembled_at: Time.now.utc + 1
      )
      store.store(updated)

      changes = store.architecture_changes
      expect(changes.size).to eq(1)
      expect(changes.first[:added]).to eq([:Emotion])
      expect(changes.first[:removed]).to eq([])
    end

    it 'detects removed extensions' do
      store.store(model)
      updated = model.merge(
        architecture: { loaded: [:Tick], loaded_count: 1, total_extensions: 5, unloaded: %i[Memory Emotion Prediction Cortex] },
        assembled_at: Time.now.utc + 1
      )
      store.store(updated)

      changes = store.architecture_changes
      expect(changes.first[:removed]).to eq([:Memory])
    end

    it 'skips snapshots with no changes' do
      3.times { |i| store.store(model.merge(assembled_at: Time.now.utc + i)) }
      expect(store.architecture_changes).to eq([])
    end
  end

  describe '#health_trend' do
    it 'extracts health scores from snapshots' do
      3.times do |i|
        store.store(model.merge(
                      cognitive:    { health: 0.8 + (i * 0.05) },
                      assembled_at: Time.now.utc + i
                    ))
      end
      trend = store.health_trend(limit: 3)
      expect(trend.size).to eq(3)
      expect(trend.last[:health]).to eq(0.9)
    end

    it 'skips snapshots without health' do
      store.store(model.merge(cognitive: { status: :no_tick_data }, assembled_at: Time.now.utc))
      expect(store.health_trend).to eq([])
    end
  end

  describe '#clear' do
    it 'removes all snapshots' do
      store.store(model)
      store.clear
      expect(store.size).to eq(0)
    end
  end
end
