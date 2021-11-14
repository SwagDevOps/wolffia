# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../utils'

# Extract and parse headers from given ``env``.
class Wolffia::HTTP::Request::Utils::HeadersParser
  def initialize(env)
    @env = env.dup.freeze
  end

  # @return [Proc]
  def to_proc
    -> { self.call }
  end

  # @return [Hash{Symbol => String}]
  def call
    env.select { |k, _| k.match?(/^HTTP_/) }.transform_keys { |key| normalizer.call(key) }.sort.to_h
  end

  protected

  # @return [Hash{String => Object}]
  attr_reader :env

  # @return [Proc]
  def normalizer
    ->(header) { header.to_s.sub(/^HTTP_/, '').downcase.to_sym }
  end
end
