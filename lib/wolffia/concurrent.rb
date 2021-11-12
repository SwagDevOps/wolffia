# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../wolffia'

# Simple loader for ``concurrent-ruby``
#
# @see http://concurrent-ruby.com/
# @see https://github.com/ruby-concurrency/concurrent-ruby
module Wolffia::Concurrent
  class << self
    # @return [Array<Symbol>] Symbols for loaded constants
    def call
      constants_from(concurrent) do |cname|
        if !self.has?(cname) and concurrent.const_get(cname).is_a?(::Class)
          self.const_set(cname, concurrent.const_get(cname))
        end
      end
    end

    def make(symbol, *args, **kwargs)
      factory.call(symbol, *args, **kwargs)
    end

    # Factory for concurrent classes
    #
    # Sample of use:
    #
    # ```ruby
    # Concurrent.factory.call(:hash)
    # ```
    #
    # @return [Class]
    def factory
      ::Class.new do
        def call(symbol, *args, **kwargs)
          ::Wolffia::Concurrent.tap(&:call).then do |mod|
            require('dry/inflector').then { ::Dry::Inflector.new }.camelize(symbol).then do |cname|
              mod.const_get(cname).then { |klass| klass.new(*args, **kwargs) }
            end
          end
        end
      end.new
    end

    protected

    # @param [Class, Module] source
    # @yield [Symbol]
    #
    # @return [Array<Symbol>]
    def constants_from(source, &block)
      source.constants.sort.map(&:to_sym).tap do |name|
        next unless block

        name.each { |v| block.call(v) }
      end
    end

    def has?(cname)
      constants_from(self).include?(cname)
    end

    def concurrent
      require('concurrent').then { ::Concurrent }
    end
  end
end
