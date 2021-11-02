# frozen_string_literal: true

# constants ---------------------------------------------------------
describe Wolffia, :wolffia do
  [
    :Bundleable,
    :Concurrent,
    :Config,
    :Container,
    :Dotenv,
    :Errors,
    :HTTP,
    :Mixins,
    :VERSION,
  ].each do |k|
    it { expect(described_class).to have_constant(k) }
  end
end
