# frozen_string_literal: true

require 'dry/inflector'
autoload(:Shammable, "#{__dir__}/shammable")

# namespace module
module Spec
  # Spec Helper module
  module Helper
    # @api private
    #
    # noinspection RubyLiteralArrayInspection
    MODULE_NAMES = [
      :sham,
      :silence_stream,
      :with_env,
    ].freeze

    MODULE_NAMES.each do |name|
      # noinspection RubyResolve
      require_relative "./helper/#{name}"

      self.instance_eval("include #{Dry::Inflector.new.camelize(name.to_s)}", __FILE__, __LINE__)
    end

    class << self
      def register
        Object.__send__(:include, self)
      end
    end
  end
end
