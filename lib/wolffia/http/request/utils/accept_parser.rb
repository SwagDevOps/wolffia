# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../utils'

# Extract and parse ``Accept`` header from given ``env``.
class Wolffia::HTTP::Request::Utils::AcceptParser
  def initialize(env)
    @env = env.dup.freeze
  end

  # @return [Proc]
  def to_proc
    -> { self.call }
  end

  # @return [Array<Wolffia::HTTP::AcceptEntry>]
  def call
    accept.scan(::Wolffia::HTTP::HEADER_VALUE_WITH_PARAMS).map! { |s| ::Wolffia::HTTP::AcceptEntry.new(s) }.sort
  end

  protected

  # @return [Hash{String => Object}]
  attr_reader :env

  # @return [String]
  def accept
    env['HTTP_ACCEPT'].to_s.empty? ? '*/*' : env['HTTP_ACCEPT']
  end
end
