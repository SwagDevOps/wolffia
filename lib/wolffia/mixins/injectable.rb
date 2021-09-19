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
module Wolffia::Mixins::Injectable
  include(::Wolffia::Mixins::Autoloaded).autoloaded(self.binding)

  # @api private
  MISSING_INJECTOR_ERROR = ::Wolffia::Errors::Core::MissingInjectorError

  # @!method auto_inject(**injection)
  #    Apply dependency injection
  #    @param [Hash{Symbol => Object}] injection
  #    @return [self]

  def initialize(**injection)
    Handler.new(self.class).injection.merge(injection).then do |dependencies|
      auto_inject(**dependencies)
    end
  end

  class << self
    def included(klass)
      klass.extend(ClassMethods)
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
  end

  # Class methods
  module ClassMethods
    # @see https://eregon.me/blog/2019/11/10/the-delegation-challenge-of-ruby27.html
    def new(...)
      Handler.new(self).call(inject: true)&.then { |deps| super(**deps) }
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
      args.concat(kwargs.to_a).map { |v| (v.is_a?(Array) ? v : [v, v]).freeze.map(&:freeze) }.then do |injectables|
        @injectables = injectables.dup.concat(injectables).freeze unless injectables.empty?
      end
    end

    # rubocop:disable Metrics/AbcSize

    # Get injectables as tuples.
    #
    # @return [Haah{Symbol => Symbol}]
    def injectables
      {}.tap do
        return @injectables.dup.to_h.map { |k, v| [k.to_sym, v.to_sym] }.to_h if @injectables

        self.ancestors[1..-1].each do |ancestor|
          next unless ancestor.methods.include?(:injectables)

          next unless ancestor.ancestors[1..-1]&.include?(::Wolffia::Mixins::Injectable)

          return ancestor.__send__(:injectables) if flags.uniq.first == true
        end
      end
    end
    # rubocop:enable Metrics/AbcSize
  end
end
