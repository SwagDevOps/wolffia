# frozen_string_literal: true

require 'kamaze/version'
VERSION = Kamaze::Version.new.freeze

# expect(something).to be_boolean
RSpec::Matchers.define :be_boolean do
  match do |value|
    [true, false].include? value
  end
end

# Constant is defined by given class or module
#
# ```
# expect(described_class).to have_constant(:VERSION)
# ```
RSpec::Matchers.define :have_constant do |const_name|
  match do |owner|
    const_name.to_s.gsub(/^::/, '').yield_self do |name|
      return false unless owner.const_defined?(name)

      # first trigger constant resolution, then search in constants array
      owner.const_defined?(name).yield_self { |b| b and owner.constants.include?(name.to_sym) }
    end
  end
end
