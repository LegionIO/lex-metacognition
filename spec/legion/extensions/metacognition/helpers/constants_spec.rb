# frozen_string_literal: true

RSpec.describe Legion::Extensions::Metacognition::Helpers::Constants do
  it 'defines MAX_SNAPSHOTS' do
    expect(described_class::MAX_SNAPSHOTS).to eq(50)
  end

  it 'defines SNAPSHOT_TTL' do
    expect(described_class::SNAPSHOT_TTL).to eq(30)
  end

  it 'defines SUBSYSTEMS as frozen array' do
    expect(described_class::SUBSYSTEMS).to be_frozen
    expect(described_class::SUBSYSTEMS).to include(:tick, :cortex, :memory)
  end

  it 'defines CAPABILITY_CATEGORIES' do
    expect(described_class::CAPABILITY_CATEGORIES).to include(:perception, :cognition, :memory, :motivation, :safety)
  end

  it 'maps every extension to a capability category' do
    described_class::EXTENSION_CAPABILITIES.each_value do |cat|
      expect(described_class::CAPABILITY_CATEGORIES).to include(cat)
    end
  end

  it 'defines HEALTH_LABELS for full range' do
    labels = described_class::HEALTH_LABELS
    expect(labels.size).to eq(5)
  end
end
