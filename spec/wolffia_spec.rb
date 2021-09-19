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
    :HasPaths,
    :Inheritance,
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

# class methods -----------------------------------------------------
describe Wolffia, :wolffia do
  :call.then do |method|
    context ".#{method}" do
      it { expect(described_class).to respond_to(method) }
      it { expect(described_class).to respond_to(method).with(0).arguments.with_keywords(:path) }
      it do
        expect { |b| described_class.public_send(method, &b) }.to yield_with_args(Wolffia)
      end
    end
  end
end
