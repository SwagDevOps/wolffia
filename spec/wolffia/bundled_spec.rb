# frozen_string_literal: true

# constants ---------------------------------------------------------
describe Wolffia, :wolffia do
  [
    :Bundleable,
    :Concurrent,
    :Container,
    :HTTP,
    :Mixins,
    :VERSION,
  ].each do |k|
    it { expect(described_class).to have_constant(k) }
  end

  it do
    lambda do
      require 'kamaze/version'

      Kamaze::Version
    end.call.tap do |klass|
      expect(described_class.const_get(:VERSION)).to be_a(klass)
    end
  end
end
