# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../concurrent'

# Provide a registry (and loader) on top of ``concurrent-ruby``.
class Wolffia::Concurrent::Registry
  include Enumerable

  # @api private
  EXCLUSION_PATTERN = /^(error|.+_error|abstract_.*)$/.freeze

  class << self
    def instance
      synchronize { @_instance ||= self.new }
    end

    protected :new

    protected

    def synchronize(&block)
      (@mutex ||= ::Mutex.new).synchronize { block.call }
    end
  end

  # @return [Hash{Symbol => Class}]
  def to_h
    items.dup
  end

  def each(&block)
    block ? items.each(&block) : to_enum(:each)
  end

  # @param [String, Symbol] key
  #
  # @return [Class]
  def [](key)
    resolve(key)
  end

  # @return [Array<Symbol>]
  def keys
    items.keys
  end

  # @param [String, Symbol] key
  #
  # @return [Class]
  def resolve(key)
    key.to_sym.then { |k| items.fetch(k) }
  end

  protected

  # @return [Hash{Symbol => Class}]
  attr_reader :items

  def initialize
    super.tap { @items = classes.freeze }.freeze
  end

  # @return [Hash]
  def symbols
    concurrent.then { |v| constants_from(v) }.map do |sym|
      [
        inflector.underscore(sym),
        concurrent.const_get(sym)
      ]
    end.to_h.transform_keys(&:to_sym)
  end

  # @return [Hash{Symbol => Class}]
  def classes
    symbols.keep_if do |_, v|
      v.is_a?(::Class)
    end.reject do |k, _|
      k.to_s.match?(EXCLUSION_PATTERN)
    end.to_h.transform_keys(&:to_sym)
  end

  # @return [Module<Concurrent>]
  def concurrent
    require('concurrent').then { ::Concurrent }
  end

  # @return [Dry::Inflector]
  def inflector
    require('dry/inflector').then { ::Dry::Inflector.new }
  end

  # @param [Class, Module] source
  # @yield [Symbol]
  #
  # @return [Array<Symbol>]
  def constants_from(source, &block)
    source.constants.sort.map(&:to_sym).tap do |name|
      next unless block

      name.each { |v| block.call(v) }
    end
  end
end
