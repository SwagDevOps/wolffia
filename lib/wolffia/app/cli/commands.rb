# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../cli'

# Add cli method
module Wolffia::App::Cli::Commands
  include(::Wolffia::Mixins::Autoloaded).autoloaded(self.binding)

  # Get registered commands.
  #
  # @api private
  MANIFEST = {
    serve: :Serve,
    console: -> { with_gems(Console: :pry) }
  }.freeze

  class << self
    def to_h
      MANIFEST.transform_values { |v| v.is_a?(::Proc) ? v.call : v }
              .compact
              .transform_values { |v| self.const_get(v) }
              .sort.to_h
    end

    protected

    # @api private
    # @param [Hash{Symbol => Array<Symbol, String>}] definition
    #
    # @return [Symbol, nil]
    def with_gems(**definition)
      definition.keys.fetch(0).tap do
        gems = ::Kernel.Array(definition.values.fetch(0))

        return nil unless defined?(:Gem)

        return nil if gems.map { |v| Gem.loaded_specs.key?(v.to_s) }.include?(false)
      end
    end
  end
end
