# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../http'

# The Accept request HTTP header indicates which content types, the client is able to understand.
#
# @see https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Accept
class Wolffia::HTTP::AcceptEntry
  def initialize(entry)
    @entry = entry.freeze
    @type = self.entry[/[^;]+/].delete(' ').freeze
    @weight = parse_entry(self.entry).delete('q') { 1.0 }.to_f

    freeze
  end

  # Sorted in descending order: better matches SHOULD BE higher.
  #
  # @param [self] other
  #
  # @return [Integer]
  def <=>(other)
    other.priority <=> self.priority
  end

  def to_str
    self.type
  end

  def to_s(full: false)
    full ? entry : to_str
  end

  def method_missing(method_name, *args, **kwargs, &block)
    respond_to_missing?(method_name) ? to_str.public_send(*args, &block) : super
  end

  def respond_to_missing?(method_name, include_private = false)
    to_str.respond_to?(method_name, include_private)
  end

  protected

  # @return [String]
  attr_reader :entry

  # @return [String]
  attr_reader :type

  # @return [Float]
  attr_reader :weight

  # Used to sort results
  #
  # @return [Array<Float, Integer>]
  def priority
    [self.weight, -self.to_str.count('*')]
  end

  # @return [Hash{string => String}]
  def parse_entry(entry)
    entry.scan(::Wolffia::HTTP::HEADER_PARAM).map do |s|
      s.strip.split('=', 2).then do |key, value|
        value = value[1..-2].gsub(/\\(.)/, '\1') if value.start_with?('"')

        [key, value]
      end
    end.to_h
  end
end
