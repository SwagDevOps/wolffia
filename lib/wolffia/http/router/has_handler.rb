# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../router'

# Define handler responding to routes
module Wolffia::HTTP::Router::HasHandler
  # @return [Proc]
  def handler
    lambda do |klass, method|
      lambda do |env|
        instance_for(klass).yield_self do |controller|
          controller.actions.fetch(method.to_sym).yield_self do |action|
            respond_with(action, env: env, controller: controller)
          end
        end
      end
    end
  end

  protected

  # Options according to handler support
  #
  # @param [Hash{Symbol => Object}] options
  #
  # @return [Hash{Symbol => Object}]
  def handleable(options)
    options.tap do
      return options unless options.key?(:to)

      options[:to] = options[:to].yield_self do |action|
        action.is_a?(Array) ? self.handler.call(*action) : action
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
end
