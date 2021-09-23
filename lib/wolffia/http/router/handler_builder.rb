# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../router'

# Build handlers responding to routes
class Wolffia::HTTP::Router::HandlerBuilder
  def initialize(resolver)
    @resolver = resolver
  end

  # Options according to handler support
  #
  # @param [Hash{Symbol => Object}] options
  #
  # @return [Hash{Symbol => Object}]
  def call(options)
    options.key?(:to) ? optionize(options) : options
  end

  protected

  # @return [Proc]
  attr_reader :resolver

  # @return [Proc]
  def handler
    # @type [Class] klass
    # @type [Symbol, String] method
    lambda do |klass, method|
      # @type [Hash{String => Object}] env
      lambda do |env|
        resolver.call(klass).then do |controller|
          controller.actions.fetch(method.to_sym).then do |action|
            respond_with(action, env: env, controller: controller)
          end
        end
      end
    end
  end

  # @param [Proc] action
  # @param [Class<Wolffia::HTTP::Controller>] controller
  # @param [Hash{String => Object}] env
  #
  # @return [Array]
  def respond_with(action, controller: nil, env: {})
    Wolffia::HTTP::Request.new(env).then { |request| action.call(request).to_a }.then do |status, headers, body|
      [
        status,
        (controller&.headers || {}).merge(headers).transform_keys(&:to_s),
        env['REQUEST_METHOD'] == 'HEAD' ? [] : body # avoid bug with (at least) thin server
      ]
    end
  end

  # Options according to handler support
  #
  # @param [Hash{Symbol => Object}] options
  #
  # @return [Hash{Symbol => Object}]
  def optionize(options)
    options.tap do
      options[:to] = options.fetch(:to).then do |action|
        action.is_a?(Array) ? self.handler.call(*action) : action
      end
    end
  end
end
