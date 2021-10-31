# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

$LOAD_PATH.unshift(__dir__)

# Namespace module
class Wolffia
  # @api private
  #
  # Simple preloader (used before autoloaded. to collect exceptions)
  class Preloader
    def initialize(**definition, &callable)
      @file_name = definition.values.fetch(0)
      @symbol_name = definition.keys.fetch(0)
      @callable = callable
    end

    def call(path: nil)
      # rubocop:disable Lint/ShadowingOuterLocalVariable
      # noinspection RubyScope
      (path || caller_locations.first.path.gsub(/\.rb$/, '')).yield_self do |path|
        require("#{path}/#{@file_name}").then do
          @symbol_name.tap { @callable&.call }
        end
      end
      # rubocop:enable Lint/ShadowingOuterLocalVariable
    end
  end

  class << self
    protected

    # @api private
    def preloader_for(**definition, &callable)
      ::Wolffia::Preloader.new(**definition, &callable)
    end
  end

  # @!parse include ::Wolffia::Bundleable
  [
    preloader_for(Bundleable: :bundleable) { self.include(::Wolffia::Bundleable) },
    preloader_for(Mixins: :mixins),
  ].map(&:call).tap do |excepts|
    # @type [::Autoloaded::Autoloader] autoloader
    include(::Wolffia::Mixins::Autoloaded).autoloaded(self.binding) do |autoloader|
      autoloader.except(*excepts)

      {
        HTTP: 'http',
      }.tap { |kwargs| autoloader.with(**kwargs.invert) }
    end
  end
end
