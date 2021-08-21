# frozen_string_literal: true

# Copyright (C) 2017-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../wolffia'

# @see https://njonsson.github.io/autoloaded/
module Wolffia::Autoloaded
  def self.included(klass)
    klass.extend(ClassMethods)

    lambda do |&block|
      klass.__send__(:autoloaded, &block)
    end
  end

  # Class-methods
  module ClassMethods
    autoload(:Pathname, 'pathname')
    autoload(:Autoloaded, 'autoloaded')

    protected

    # @yield [autoloadeding]
    #
    # @yieldreturn [Autoloaded::Autoloader]
    def autoloaded(&block)
      Autoloaded.module(&block)
    end
  end
end
