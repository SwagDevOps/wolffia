# frozen_string_literal: true

# constants ---------------------------------------------------------
describe Wolffia::App, :'wolffia/app' do
  [
    :Cli,
    :Inheritance,
    :Paths
  ].each do |k|
    it { expect(described_class).to have_constant(k) }
  end
end

# App.call ----------------------------------------------------------
describe Wolffia::App, :'wolffia/app' do
  :call.then do |method|
    context ".#{method}" do
      it { expect(described_class).to respond_to(method) }
      it { expect(described_class).to respond_to(method).with(0).arguments.with_keywords(:path) }
      it do
        expect { |b| described_class.public_send(method, &b) }.to yield_with_args(described_class)
      end
    end
  end
end

# instance methods --------------------------------------------------
describe Wolffia::App, :'wolffia/app' do
  let(:subject) { described_class.allocate }

  it { expect(subject).to respond_to(:cli).with(0).arguments }
  it { expect(subject).to respond_to(:environment).with(0).arguments }
  it { expect(subject).to respond_to(:run).with(1).arguments }
end

# test apps starting with valid env ---------------------------------
describe Wolffia::App, :'wolffia/app' do
  sham(:app).valid_env_keys.each do |sample_key|
    context "#dotenv (sample: #{sample_key})" do
      let(:env) { sham(:app).expectations.fetch(sample_key).env }
      let(:subject) { sham(:app).builders.fetch(sample_key).call }

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

# test apps starting with invalid env -------------------------------
describe Wolffia::App, :'wolffia/app' do
  sham(:app).invalid_env_keys.each do |sample_key|
    context ".call (sample: #{sample_key})" do
      let(:builder) { sham(:app).builders.fetch(sample_key) }
      let(:error_message) { sham(:app).expectations.fetch(sample_key).error.fetch('message') }

      it do
        expect { builder.call }.to raise_error(::RuntimeError, error_message)
      end
    end
  end
end
