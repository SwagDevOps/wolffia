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
      allocate

      super(...)
    end

    def allocate
      __send__(:include, injector[*injectables]) if !injectables.to_a.empty? and injector

      super
    end

    protected

    # @!method __app__
    #   @api private
    #   @see Wolffia.call
    #   @return [Wolffia]

    attr_reader :injectables

    def injector
      (@injector || __app__.injector).tap do |v|
        raise RuntimeError, 'can not retrieve injector' unless v
      end
    end

    def injector=(injector)
      -> { injector }.tap do |f|
        @injector = f.call

        self.allocate
      end.call
    end
  end
end
