# frozen_string_literal: true

require_relative '../helper'

# Shammable methods
module Spec::Helper::WithEnv
  autoload(:ClimateControl, 'climate_control')

  # @param env [Hash]
  def with_env(env)
    (@env_mutex ||= Mutex.new).synchronize do
      original_env = ENV.to_hash
      ENV.replace(env.transform_keys(&:to_s))

      yield if block_given?
    ensure
      ENV.replace(original_env)
    end
  end

  # @param env [Hash]
  #
  # @see https://github.com/thoughtbot/climate_control
  def with_modified_env(env, &block)
    ClimateControl.modify(env, &block)
  end
end
