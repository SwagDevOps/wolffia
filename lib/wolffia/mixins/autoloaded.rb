# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../mixins'

# Autoload easyfier.
#
# Sample of use:
#
# ```ruby
# include(::Wolffia::Mixins::Autoloaded).autoloaded(self.binding)
# ```
#
# @see https://njonsson.github.io/autoloaded/
# @see https://github.com/njonsson/autoloaded
module Wolffia::Mixins::Autoloaded
  class << self
    def included(klass)
      klass.extend(ClassMethods)
    end
  end

  # Class-methods
  module ClassMethods
    autoload(:Autoloaded, 'autoloaded')

    protected

    # Autoloads constants that match files in the source directory.
    #
    # @param [Binding] binding
    #
    # @yield [autoloader]
    # @yieldreturn [::Autoloaded::Autoloader]
    def autoloaded(binding = nil, &block)
      block ||= lambda do
        return nil unless binding

        (->(*) {}).tap do |functor|
          functor.singleton_class.__send__(:define_method, :binding) { binding }
        end
      end.call

      autoload(:Autoloaded, 'autoloaded').then { Autoloaded.module(&block) }
    end
  end
end
