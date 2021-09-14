# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../mixins'

# Provide class-level injector accessor  and inject method
#
# @see https://dry-rb.org/gems/dry-auto_inject/0.6/basic-usage/
module Wolffia::Mixins::Injectable
  # @api private
  MISSING_INJECTOR_ERROR = ::Wolffia::Errors::Core::MissingInjectorError

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  # Class-methods
  module ClassMethods
    def inject(*args)
      @injectables = args.compact ? args : nil
    end

    # @see https://eregon.me/blog/2019/11/10/the-delegation-challenge-of-ruby27.html
    def new(...)
      include_injector.yield_self { super(...) }
    end

    def allocate(...)
      include_injector
    rescue MISSING_INJECTOR_ERROR # app is not started
      super
    ensure
      super
    end

    protected

    attr_reader :injectables

    # @return [Wolffia::Injector]
    def injector
      # @type [Wolffia, nil] app
      (Kernel.respond_to?(:__app__) ? Kernel.__app__ : nil).yield_self do |app|
        (@injector || app&.injector).tap do |v|
          raise MISSING_INJECTOR_ERROR, 'can not retrieve injector' if v.nil?
        end
      end
    end

    # @param [Wolffia:;Injector] injector
    def injector=(injector)
      (@injector = injector).tap { include_injector }
    end

    # @api private
    #
    # @param [Wolffia::Injector] injector
    #
    # @return [Wolffia::Injector]
    def include_injector(injector = self.injector)
      __send__(:include, injector[*injectables]) unless injectables.to_a.empty?
    end
  end
end
