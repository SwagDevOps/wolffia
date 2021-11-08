# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../mixins'

# Provide class-level injector accessor and inject method
#
# Some inspiration taken from ``dry-auto_inject``.
#
# Sample of use:
#
# ```ruby
# class Sample
#   include(::Wolffia::Mixins::Injectable)
#   auto_inject(:parrot, paths: 'app.paths', bird: :parrot)
#
#   def repeat(sentence)
#     self.parrot.call(sentence)
#   end
# end
# ```
module Wolffia::Mixins::Injectable
  include(::Wolffia::Mixins::Autoloaded).autoloaded(self.binding)

  # @!method auto_inject(**injection)
  #    @!scope class
  #    @!visibility protected
  #
  #    Apply dependency injection
  #
  #    @param [Hash{Symbol => Object}] injection
  #    @return [self]

  # @!attribute [r] injectables
  #    @!scope class
  #    @!visibility protected
  #    @api private
  #
  #    Get injectables
  #    @see ClassMethods.injectables
  #
  #    @return [Hash{Symbol => Symbol}]

  # @api private
  MISSING_INJECTOR_ERROR = ::Wolffia::Errors::Core::MissingInjectorError

  # rubocop:disable Lint/UnusedMethodArgument

  def initialize(*args, **injection)
    Handler.new(self.class).injection.merge(injection).then do |dependencies|
      auto_inject(**dependencies)
    end
  end
  # rubocop:enable Lint/UnusedMethodArgument

  class << self
    def included(klass)
      included_handler.tap do |handler|
        return handler.call(klass) if klass.is_a?(Class)

        klass.singleton_class.__send__(:define_method, __method__) { |c| handler.call(c) }
      end
    end

    # @param [Wolffia::Container] container
    #
    # @return [Class]
    def register_container(container)
      self.singleton_class.tap do |klass|
        klass.define_method(:container_retriever) do
          -> { container }
        end
      end
    end

    # @api private
    def container_retriever
      -> { raise MISSING_INJECTOR_ERROR, 'can not retrieve container' }
    end

    protected

    # @api private
    def included_handler
      ->(klass) { klass.extend(ClassMethods) if klass.is_a?(Class) }
    end
  end

  # Class methods
  module ClassMethods
    def new(*args)
      Handler.new(self).call(inject: true)&.then { |deps| super(*args, **deps) }
    rescue MISSING_INJECTOR_ERROR => _e # app is not started
      super
    end

    def allocate(...)
      Handler.new(self).call.then { super }
    rescue MISSING_INJECTOR_ERROR => _e # app is not started
      super
    end

    protected

    def auto_inject(*args, **kwargs)
      args.concat(kwargs.to_a)
          .map { |v| (v.is_a?(Array) ? v : [v, v].map(&:to_sym)).freeze.map(&:freeze) }
          .then { |h| @injectables = h.to_h.merge(@injectables || {}).freeze unless h.empty? }
    end

    # Get injectables declaration.
    #
    # @api private
    # @return [Hash{Symbol => Symbol}]
    def injectables
      Visitor.new(self).call(@injectables.dup)
    end
  end
end
