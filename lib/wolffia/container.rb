# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../wolffia'
require 'dry-container'

# A simple, thread-safe container, dependency injection system in combination with dry-auto_inject.
#
# @see https://dry-rb.org/gems/dry-container/0.7/
class Wolffia::Container < ::Dry::Container
  autoload(:Pathname, 'pathname')
  include(::Wolffia::Mixins::Autoloaded).autoloaded(self.binding)

  class << self
    # @see Wolffia::Container::Builder#initialize
    #
    # @return [Wolffia::Container]
    def build(*args)
      Builder.call(*args)
    end
  end

  # @return [Wolffia::Container::Injector]
  def injector
    Injector.new(self)
  end

  def register(key, contents = nil, options = {}, &block)
    if self.key?(key)
      ::Dry::Container.new.tap do |container|
        container.register(key, contents, options, &block)

        return self.merge(container)
      end
    end

    super
  end

  alias_method '[]=', 'register'

  # Populate given key with given block return value, suing nil value for missing keys.
  #
  # @param [String, Symbol] key
  #
  # @return [self]
  def populate(key, &blk)
    loop do
      self[key.to_sym] = blk.call(self)
    rescue ::Dry::Container::Error => e
      e.message.match(/^Nothing\s+registered\s+with\s+the\s+key\s+(:(.*)|"(.*)")$/).to_a[2].tap do |m|
        # self.register(m.to_sym, memoize: true) { self.resolve(m.to_sym) }
        self[m.to_sym] = nil
      end
    else
      return self
    end
  end

  # @return [self]
  def load_file(filepath)
    self.tap do
      Pathname.new(filepath).yield_self { |file| self.instance_eval(file.read, file.to_s, 1) }
    end
  end
end
