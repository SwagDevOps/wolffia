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

  class << self
    protected

    # @api private
    def loader_for(**definition, &callable)
      Class.new do
        def initialize(**definition, &callable)
          @file_name = definition.values.fetch(0)
          @symbol_name = definition.keys.fetch(0)
          @callable = callable
        end

        def call(path: nil)
          # rubocop:disable Lint/ShadowingOuterLocalVariable
          # noinspection RubyScope
          (path || caller_locations.first.path.gsub(/\.rb$/, '')).yield_self do |path|
            require("#{path}/#{@file_name}").then do
              @symbol_name.tap { @callable.call }
            end
          end
          # rubocop:enable Lint/ShadowingOuterLocalVariable
        end
      end.new(**definition, &callable)
    end
  end

  # @!parse include ::Wolffia::Bundleable
  # @!parse include ::Wolffia::Mixins::Autoloaded
  # @!parse include ::Wolffia::HasCli
  # @!parse include ::Wolffia::HasPaths
  # @!parse include ::Wolffia::Inheritance
  [
    loader_for(Bundleable: :bundleable) { self.include(::Wolffia::Bundleable) },
    loader_for(Mixins: :mixins) { self.include(::Wolffia::Mixins::Autoloaded) },
    loader_for(HasCli: :has_cli) { self.include(::Wolffia::HasCli) },
    loader_for(HasPaths: :has_paths) { self.include(::Wolffia::HasPaths) },
    loader_for(Inheritance: :inheritance) { self.include(::Wolffia::Inheritance) },
    loader_for(VERSION: :version) { self.autoload(:VERSION, "#{__dir__}/wolffia/version") }
  ].map(&:call).tap do |excepts|
    self.autoloaded do |autoloading|
      autoloading.except(*excepts)

      {
        HTTP: 'http',
      }.tap { |kwargs| autoloading.with(**kwargs.invert) }
    end
  end

  # @return [Environment]
  def environment
    container.nil? ? Environment.new : container&.resolve(:'app.env')
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
    Concurrent.call

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

  # @param [Hash{Symbol => Object}] volatile
  #
  # @return [Wolffia::Container]
  def build_container(volatile = {})
    dotenv.then { Container.build(services_path, self.volatile.merge(volatile)) }
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
