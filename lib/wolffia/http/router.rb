# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../http'
require 'hanami/router'

# HTTP router
class Wolffia::HTTP::Router < Hanami::Router
  autoload(:Pathname, 'pathname')

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

  # Load routes from given file.
  #
  # @param [String] filepath
  #
  # @return [self]
  def load_file(filepath)
    self.tap do
      return self unless filepath

      Pathname.new(filepath).yield_self do |file|
        self.instance_eval(file.read, file.to_s, 1) if file.exist? and file.readable?
      end
    end
  end

  protected

  # @return [Wolffia::Container::Injector]
  attr_reader :injector

  attr_accessor :controllers

  def injector=(injector)
    (@injector = injector).tap do
      @controllers ||= {}
      self.controllers.to_h.each_key do |klass|
        @controllers[klass] = self.instance_for(klass)
      end
    end
  end

  # Get an instance for given controller class.
  #
  # @param [Class<Wolffia::HTTP::Controller>] controller
  #
  # @return [Wolffia::HTTP::Controller]
  def instance_for(controller)
    @controllers ||= {}
    @controllers[controller] ||= controller.tap { |c| c.__send__(:injector=, injector) }.new.tap do |instance|
      instance.actions.yield_self do |actions|
        instance.singleton_class.__send__(:define_method, :actions) { actions.transform_keys(&:to_sym) }
      end
    end
  end

  # @param [Proc] action
  # @param [Hash{String => Object}] env
  #
  # @return [Array]
  def respond_with(action, controller: nil, env: {})
    action.call(env).to_a.yield_self do |response|
      response.yield_self do |status, headers, body|
        [
          status,
          (controller&.headers || {}).merge(headers).transform_keys(&:to_s),
          body,
        ]
      end
    end
  end
end
