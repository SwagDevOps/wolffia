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

  :VERSION.then do |const|
    context ".#{const}" do
      let(:version_class) do
        (require 'kamaze/version').then { Kamaze::Version }
      end

      it { expect(described_class.const_get(const)).to be_a(version_class) }
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

# test some apps ------------------------------------------------------
describe Wolffia, :wolffia do
  sham(:app).valid_env_keys.each do |sample_key|
    context "#dotenv (sample: #{sample_key})" do
      let(:subject) { sham(:app).builders.fetch(sample_key).call }
      let(:env) { sham(:app).expectations.fetch(sample_key).env }

      it { expect(subject.__send__(:dotenv)).to be_a(::Hash) }
      it { expect(subject.__send__(:dotenv)).to eq(env) }
    end

    context ".instance (sample: #{sample_key})" do
      let(:builder) { sham(:app).builders.fetch(sample_key) }
      let(:subject) { builder.call }
      let(:subject_class) { subject.class }

      it { expect(subject_class.instance).to be(subject) }
    end
  end
end
