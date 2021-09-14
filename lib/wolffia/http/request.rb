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
    @env = env
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
    env.select { |k, _| k.match?(/^HTTP_/) }.then { |headers| prepare_headers(headers) }
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

  # @param [Hash{String => String}] headers
  #
  # @return [Hash{String => String}]
  def prepare_headers(headers)
    lambda do |header|
      header.to_s.sub(/^HTTP_/, '').split('_').map(&:capitalize).join('-').freeze
    end.yield_self do |normalizer|
      headers.transform_keys { |header| normalizer.call(header) }.sort.to_h
    end
  end
end
