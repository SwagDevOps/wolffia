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
    def call(name = nil)
      constants_from(self) { |cname| self.remove_const(cname) }

      # noinspection RubyResolve
      (require ['concurrent', name].compact.join('/')).tap do
        constants_from(::Concurrent) do |cname|
          self.const_set(cname, ::Concurrent.const_get(cname))
        end
      end
    end

    protected

    # @param [Class, Module] source
    # @yield [Symbol]
    #
    # @return [Array<Symbol>]
    def constants_from(source, &block)
      source.constants.map(&:to_sym).tap do |name|
        next unless block

        name.each { |v| block.call(v) }
      end
    end
  end
end
