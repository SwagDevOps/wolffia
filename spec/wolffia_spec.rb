# frozen_string_literal: true

# constants ---------------------------------------------------------
describe Wolffia, :wolffia do
  [
    :App,
    :Bundleable,
    :Cli,
    :Concurrent,
    :Config,
    :Container,
    :Dotenv,
    :Environment,
    :Errors,
    :HTTP,
    :Logger,
    :Mixins,
    :VERSION,
  ].each do |k|
    it { expect(described_class).to have_constant(k) }
  end
end
