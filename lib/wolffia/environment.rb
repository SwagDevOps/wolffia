# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../wolffia'

# Get an object representation of the current environment (name).
class Wolffia::Environment
  include(::Wolffia::Mixins::Env)

  # @api private
  DEFAULT = 'development'

  # @api private
  ENV_KEYS = %w[APP_ENV RACK_ENV].freeze

  def initialize
    @state = make_state.freeze

    self.freeze
  end

  def to_sym
    # rubocop:disable Style/RedundantInterpolation
    "#{self}".to_sym
    # rubocop:enable Style/RedundantInterpolation
  end

  def to_str
    to_a.reject { |v| [nil, ''].include?(v) }.fetch(0)
  end

  alias to_s to_str

  def ==(other)
    -> { super }.tap do
      return other == to_str if other.is_a?(::String)

      return other == to_sym if other.is_a?(::Symbol)
    end.call
  end

  def to_a
    self.state.dup
  end

  protected

  attr_reader :state

  def make_state
    ENV_KEYS.map { |k| env(k) }.concat([DEFAULT]).map { |v| v&.to_s.freeze }
  end
end
