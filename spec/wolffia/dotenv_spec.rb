# frozen_string_literal: true

autoload(:Pathname, 'pathname')

# methods signatures ------------------------------------------------
describe Wolffia::Dotenv, :'wolffia/dotenv' do
  let(:subject) { described_class.allocate }
  :new.tap do |method|
    it { expect(described_class).to respond_to(method).with(0).arguments.with_keywords(:path) }
    it { expect(described_class).to respond_to(method).with(0).arguments.with_keywords(:filename) }
  end

  it { expect(subject).to respond_to(:call).with(0).arguments }
  it { expect(subject).to respond_to(:to_s).with(0).arguments }
  it { expect(subject).to respond_to(:to_path).with(0).arguments }
end

# public methods ----------------------------------------------------
describe Wolffia::Dotenv, :'wolffia/dotenv' do
  sham(:app).paths.each do |_, path|
    [:to_s, :to_path].each do |method|
      context "##{method}" do
        let(:path) { Pathname.new(path) }
        let(:filpath) { path.join('.env') }
        let(:subject) { described_class.new(path: path) }

        it { expect(subject.public_send(method)).to be_a(String) }
        it { expect(subject.public_send(method)).to eq(filpath.to_s) }
      end
    end
  end
end

# internal state ----------------------------------------------------
describe Wolffia::Dotenv, :'wolffia/dotenv' do
  sham(:app).paths.each do |_, path|
    context '#path' do
      let(:path) { Pathname.new(path) }
      let(:subject) { described_class.new(path: path) }

      it { expect(subject.__send__(:path)).to eq(path) }
    end

    context '#validator' do
      let(:path) { Pathname.new(path) }
      let(:subject) { described_class.new(path: path) }

      it { expect(subject.__send__(:validator)).to be(DotenvValidator) }
    end

    context '#validator.root' do
      let(:path) { Pathname.new(path) }
      let(:subject) { described_class.new(path: path) }

      it { expect(subject.__send__(:validator).root).to eq(path) }
    end
  end
end
