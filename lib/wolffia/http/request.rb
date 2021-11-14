# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../http'

# Describe an HTTP request
class Wolffia::HTTP::Request
  include(::Wolffia::Mixins::Autoloaded).autoloaded(self.binding)

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

  # Get HTTP headers (indexed as lowercase symbols).
  #
  # @return [Hash{Symbol => String}]
  def headers
    ::Wolffia::HTTP::Request::Utils::HeadersParser.new(env).then do |parser|
      self.memoize(:headers) { parser.call }
    end
  end

  # Returns an array of acceptable media types for the response
  def accept
    ::Wolffia::HTTP::Request::Utils::AcceptParser.new(env).then do |parser|
      self.memoize(:accept) { parser.call }
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

  protected

  # @return [Concurrent::Hash]
  attr_reader :memo

  def memoize(key, &block)
    self.memo[key.to_sym] ||= block.call
  end
end
