# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../injectable'

# Retrieve injectables by visiting the class hierarchy.
#
# Visitor only visit the parent class.
class Wolffia::Mixins::Injectable::Visitor
  def initialize(subject, visitable: ::Wolffia::Mixins::Injectable)
    @subject = subject
    @visitable = visitable
  end

  # @param [Hash, Array] injectables
  #
  # @return [Hash{Symbol => Symbol}]
  def call(injectables)
    injectables = (injectables || {}).dup.map { |k, v| [k.to_sym, v.to_sym] }.to_h

    (visit || {}).then { |h| h.merge(injectables) }
  end

  # Inspect the class hierarchy.
  #
  # @return [Hash{Class => Hash}, nil]
  def visit
    self.ancestor&.then { |ancestor| injectables_for(ancestor) }
  end

  protected

  # @return [Class]
  attr_reader :subject

  # @return [Module]
  attr_reader :visitable

  # @return [Module, Class, nil]
  def ancestor
    subject.ancestors[1..-1].first
  end

  # Denote given ancestor is injectable.
  #
  # @param [Class, Module] ancestor
  #
  # @return [Boolean]
  def injectable?(ancestor)
    ancestor.is_a?(Class) and ancestor.ancestors[1..-1]&.include?(visitable)
  end

  # Get injectables for given ancestor.
  #
  # @param [Class] ancestor
  #
  # @return [Hash{Symbol => Symbol}]
  def injectables_for(ancestor)
    injectable?(ancestor) and ancestor.methods.include?(:injectables) ? ancestor.__send__(:injectables) : {}
  end
end
