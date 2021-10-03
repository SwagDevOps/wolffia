# frozen_string_literal: true

describe Wolffia::VERSION, :'wolffia/version' do
  let(:version_class) do
    (require 'kamaze/version').then { ::Kamaze::Version }
  end

  it { expect(subject).to be_a(version_class) }

  sham(:version).to_h.each do |k, v|
    it { expect(subject).to respond_to(k).with(0).arguments }

    context "##{k}" do
      it { expect(subject.public_send(k)).to eq(v) }
    end
  end
end
