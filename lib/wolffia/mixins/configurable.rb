# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../mixins'

# Simple mixin to add configuration behaviour to instances.
#
# @see https://dry-rb.org/gems/dry-configurable/0.11/
#
# Sample of use:
#
# ```ruby
# class Sampler
#   include(::Wolffia::Mixins::Injectable)
#   include(::Wolffia::Mixins::Configurable)
#
#   auto_inject(storage_path: 'app.paths.storage_path')
#
#   def initialize(**injection, &block)
#     super(**injection)
#
#     self.configurable do
#       setting(:name, default: DEFAULT_NAME)
#       setting(:directory, default: storage_path.join('samples'))
#     end.configure(&block).freeze
#   end
#
#   protected
#
#   # @return [Symbol]
#   def name
#     self.config.name.to_sym
#   end
#
#   # @return [Pathname]
#   def directory
#     Pathname.new(self.config.directory).dup
#   end
# end
# ```
module Wolffia::Mixins::Configurable
  protected

  # @!attribute [r,w] config
  #   @return [Dry::Configurable::Config]

  # Configure instance.
  #
  # @yield [config]
  # @yieldreturn [Dry::Configurable::Config]
  # @return [self]
  def configure(&blk)
    self.tap do
      blk&.call(self.config)

      self.config.freeze
    end
  end

  # Boilerplate to load ``dry/configurable``
  #
  # @yieldreturn [self]
  # @return [self]
  def configurable(&blk)
    self.tap do
      [
        "require 'dry/configurable'",
        'self.extend(::Dry::Configurable)',
        'self.singleton_class.__send__(:protected, :config)',
      ].join("\n").tap { |s| self.instance_eval(s) }

      blk&.call(self)
    end
  end
end
