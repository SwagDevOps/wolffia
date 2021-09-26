# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../container'

# Methods related to volatile varaibles storage.
module Wolffia::Container::Volatile
  protected

  # @return [Struct, nil]
  attr_reader :volatile

  # Store given variables as volatile.
  #
  # @param [Hash{Symbol => Object}]
  #
  # @return [self]
  def volatilize(variables, &block)
    self.tap do
      (@volatile_mutex ||= ::Mutex.new).synchronize do
        make_volatile(variables).then { |v| instance_variable_set('@volatile', v) }
        block&.call
        instance_variable_set('@volatile', nil)
      end
    end
  end

  # @param [Hash{Symbol => Object}]
  #
  # @return [Struct, nil]
  def make_volatile(variables)
    variables.to_h.then do |v|
      v.empty? ? nil : ::Struct.new(*v.keys).new(*v.values).freeze
    end
  end

  # Retriev given varaible by name.
  #
  # @param [Symbol] name
  #
  # @return [Object]
  def volatile_get(name)
    volatile.then do |b|
      b.public_send(name)
    rescue ::NoMethodError
      raise ::NameError, "variable `#{name}' is not defined in #{b}"
    end
  end
end
