# frozen_string_literal: true

autoload(:Pathname, 'pathname')

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
