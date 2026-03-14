# frozen_string_literal: true

RSpec.describe Legion::Extensions::Metacognition::Client do
  describe '#initialize' do
    it 'creates a default snapshot store' do
      client = described_class.new
      expect(client.snapshot_store).to be_a(Legion::Extensions::Metacognition::Helpers::SnapshotStore)
    end

    it 'accepts an injected snapshot store' do
      store = Legion::Extensions::Metacognition::Helpers::SnapshotStore.new
      client = described_class.new(snapshot_store: store)
      expect(client.snapshot_store).to equal(store)
    end
  end

  it 'includes Runners::Metacognition' do
    expect(described_class.ancestors).to include(Legion::Extensions::Metacognition::Runners::Metacognition)
  end
end
