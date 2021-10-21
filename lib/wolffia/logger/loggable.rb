# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../logger'

# Loggable item.
class Wolffia::Logger::Loggable
  def initialize(severity:, message:, context: nil)
    @state = Struct.new(:severity, :message, :context).new(Logger.const_get(severity), message, context).freeze

    freeze
  end

  def exception?
    state.message.is_a?(::Exception)
  end

  def message
    state.message.tap do |message|
      return [message.class, message.message.inspect].join(' ') if exception?
    end
  end

  def context
    state.context.tap do |context|
      # rubocop:disable Style/ParenthesesAroundCondition
      return state.message.backtrace[0..9] if (exception? and context.nil? and state.message.backtrace)
      # rubocop:enable Style/ParenthesesAroundCondition
    end
  end

  def severity
    state.severity
  end

  def lines
    self.context.then do |context|
      message.lines.map do |line|
        (context.nil? ? line : "#{line} #{JSON.generate(context)}").strip
      end
    end
  end

  protected

  # @return [Struct]
  attr_reader :state
end
