# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../http'

# Describe an HTTP request
class Wolffia::HTTP::Request
  # @return [Hash{String => Object}]
  attr_reader :env

  def initialize(env)
    super().tap do
      @env = env.dup.freeze
      @memo = ::Wolffia::Concurrent.factory.make(:hash)
    end.freeze
  end

  # Get router params.
  #
  # @return [Hash{Symbol => String}]
  def params
    (env['router.params'] || {}).transform_keys(&:to_sym)
  end

  # Get HTTP headers.
  #
  # @return [Hash{String => String}]
  def headers
    self.memoize(:headers) do
      env.select { |k, _| k.match?(/^HTTP_/) }.then { |headers| prepare_headers(headers) }
    end
  end

  # @return [Symbol, nil]
  def method
    env.fetch('REQUEST_METHOD')&.upcase.yield_self do |method|
      method ? method.to_sym : nil
    end
  end

  # @return [String, nil]
  def path
    env.fetch('REQUEST_PATH', nil)&.to_s
  end

  # @return [String, nil]
  def uri
    env.fetch('REQUEST_URI', nil)&.to_s
  end

  alias to_h env

  # Returns an array of acceptable media types for the response
  def accept
    self.memoize(:accept) { make_accept(self.env.dup) }
  end

  protected

  # @return [Concurrent::Hash]
  attr_reader :memo

  # @param [Hash{String => String}] headers
  #
  # @return [Hash{Symbol => String}]
  def prepare_headers(headers)
    lambda do |header|
      header.to_s.sub(/^HTTP_/, '').downcase
    end.yield_self do |normalizer|
      headers.transform_keys { |header| normalizer.call(header).to_sym }.sort.to_h
    end
  end

  # @param [Hash{String => Object}] env
  #
  # @return [Array<Wolffia::HTTP::AcceptEntry>]
  def make_accept(env)
    (env['HTTP_ACCEPT'].to_s.empty? ? '*/*' : env['HTTP_ACCEPT']).to_s.then do |accpet|
      accpet.scan(::Wolffia::HTTP::HEADER_VALUE_WITH_PARAMS).map! { |s| ::Wolffia::HTTP::AcceptEntry.new(s) }.sort
    end
  end

  def memoize(key, &block)
    self.memo[key.to_sym] ||= block.call
  end
end
