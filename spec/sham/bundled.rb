# frozen_string_literal: true

{
  builder: lambda do |base: Class|
    base.new do
      class << self
        include Stibium::Bundled
      end
    end
  end,
}
