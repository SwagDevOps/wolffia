# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

$LOAD_PATH.unshift(__dir__)

# App class, acts as a singleton.
#
# Sample of use:
#
# ```ruby
# App = Class.new(Wolffia).call
# ```
class Wolffia
  autoload(:Pathname, 'pathname')

  "#{__dir__}/wolffia".yield_self do |path|
    self.tap do
      {
        bundleable: -> { self.include(::Wolffia::Bundleable) },
        mixins: -> { self.include(::Wolffia::Mixins::Autoloaded) },
        has_paths: -> { self.include(::Wolffia::HasPaths) },
        inheritance: -> { self.include(::Wolffia::Inheritance) },
        version: -> { self.autoload(:VERSION, "#{path}/version") }
      }.map do |s, f|
        # noinspection RubyResolve
        require("#{path}/#{s}").then { f&.call }
      end
    end.autoloaded do |autoloading|
      autoloading.except(:Bundleable, :Mixins, :HasPaths, :Inheritance, :VERSION)

      {
        HTTP: 'http',
      }.tap { |kwargs| autoloading.with(**kwargs.invert) }
    end
  end

  # @return [Environment]
  def environment
    container.nil? ? Environment.new : container&.resolve(:'app.environment')
  end

  # @param [Rack::Builder] builder
  def run(builder)
    self.tap do
      self.middleware_from(builder).tap do |middleware|
        container['http.middleware'] = middleware.register
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
    Concurrent.call

    self.path = path.freeze
    self.container = build_container

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
    Dotenv.new(path: self.path).call
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

  # @return [Wolffia::Container]
  def build_container
    dotenv.then { Container.build(services_path, volatile) }
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
