# frozen_string_literal: true

describe Wolffia::Environment, :'wolffia/environment' do
  it { expect(described_class).to respond_to(:new).with(0).arguments }
  it { expect(subject).to be_frozen }

  sham(:environment).environments.to_h.each do |_, v|
    [:to_s, :to_sym].each do |method|
      context "##{method}" do
        let!(:expected) { v.expected.public_send(method) }
        let!(:subject) do
          with_env(v.env) { described_class.new }
        end

        it { expect(subject.public_send(method)).to eq(expected) }
      end
    end
  end
end

describe Wolffia::Environment, :'wolffia/environment' do
  sham(:environment).environments.to_h.each do |_, v|
    [:to_s, :to_sym].each do |method|
      context "#==(#{v.expected.inspect})" do
        let!(:expected) { v.expected.public_send(method) }
        let!(:subject) do
          with_env(v.env) { described_class.new }
        end

        it { expect(subject == expected).to be true }
      end
    end
  end
end
