# frozen_string_literal: true

# Copyright (C) 2017-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../wolffia'

# App class, acts as a singleton.
#
# Sample of use:
#
# ```ruby
# App = Class.new(::Wolffia::App).call
# ```
class Wolffia::App
  autoload(:Pathname, 'pathname')

  include(::Wolffia::Mixins::Autoloaded).autoloaded(self.binding)
  include(::Wolffia::App::Inheritance)
  include(::Wolffia::App::Cli)
  include(::Wolffia::App::Paths)

  # @return [Environment]
  def environment
    container.nil? ? ::Wolffia::Environment.new : container&.resolve(:'app.env')
  end

  # @param [Rack::Builder] builder
  def run(builder)
    self.tap do
      self.middleware_from(builder).tap do |middleware|
        container['http.middleware'] = middleware.register if builder.respond_to?(:use)
      end

      container.resolve(:'http.router').then { |router| builder.run(router) }
    end
  end

  class << self
    # @return [Wolffia]
    def call(path: nil, &block)
      (path || caller_locations.first.path).yield_self do |fp|
        synchronize do
          (@instance ||= self.new(path: fp)).tap { |app| block&.call(app) }
        end
      end
    end

    # @return [Wolffia]
    def instance
      caller_locations.first.path.yield_self { |path| self.call(path: path) }
    end

    protected :new

    protected

    def synchronize(&block)
      (@mutex ||= ::Mutex.new).synchronize { block.call }
    end
  end

  protected

  # @return [Wolffia::Container]
  attr_accessor :container

  alias services container

  # @return [Pathname]
  attr_reader :path

  alias base_path path

  def initialize(path: nil)
    self.path = path.freeze
    self.container = build_container({ 'app.instance': self })

    self.register.freeze
  end

  # Name for the method used to regsiter app on  ``Kernel``.
  #
  # @return [Symbol, nil]
  def registered_as
    :__app__
  end

  # Set base path for application
  #
  # @param [String, Pathname] path
  #
  # @return [Pathname]
  def path=(path)
    Pathname.new(path).yield_self { |fp| fp.directory? ? fp : fp.dirname }.realpath.freeze.tap do |dir|
      @path = dir
    end
  end

  # Load dotenv file.
  #
  # @return [Hash]
  def dotenv
    ::Wolffia::Dotenv.new(path: self.path).call
  end

  # Get injectable mixin.
  #
  # After startup completion you SHOULD freeze it:
  #
  # ```ruby
  # injectable.freeze
  # ```
  #
  # @return [Module]
  def injectable
    ::Wolffia::Mixins::Injectable
  end

  # Register appplication startup completion.
  #
  # Register ``__app__`` helper method
  # Register ``container`` on injectable mixin
  #
  # @return [self]
  def register
    self.tap do |app|
      ::Kernel.__send__(:define_method, self.registered_as) { app } if registered_as
      injectable.register_container(container)
    end
  end

  # @param [Hash{Symbol => Object}] volatile
  #
  # @return [Wolffia::Container]
  def build_container(volatile = {})
    dotenv.then { ::Wolffia::Container.build(services_path, self.volatile.merge(volatile)) }
  end

  # Make a middleware from given builder.
  #
  # @api private
  #
  # @param [Rack::Builder] builder
  def middleware_from(builder)
    ::Wolffia::HTTP::Middleware.new(builder, container, load_path: middlewares_path, loadables: self.middlewares)
  end

  # Get volatile variables used to build container.
  #
  # @api private
  #
  # @return {Hash{Symbol => Object}}
  def volatile
    {
      commands: self.commands,
      environment: self.environment,
      paths: self.paths,
      settings_params: [config_path, self.environment],
      router_options: {
        loadables: self.routes,
        load_path: self.routes_path,
      },
    }
  end
end
