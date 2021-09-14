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
      # noinspection RubyResolve
      [:bundleable, :autoloaded].map { |s| require("#{path}/#{s}") }.then do
        include(::Wolffia::Bundleable)
        include(::Wolffia::Autoloaded)
        autoload(:VERSION, "#{path}/version")
      end
    end.autoloaded do |autoloading|
      autoloading.except(:Autoloaded, :Bundleable, :VERSION)

      {
        HTTP: 'http',
      }.tap { |kwargs| autoloading.with(**kwargs.invert) }
    end
  end

  include(Wolffia::Mixins::Env)
  include(Wolffia::HasPaths)

  def environment
    container&.resolve(:'app.environment')
  end

  # @return [Wolffia::Container::Injector, nil]
  def injector
    @container&.injector
  end

  # Rack middlewares
  #
  # @return [Array<String, Symbol>]
  def middlewares
    []
  end

  # @param [Rack::Builder] builder
  def run(builder)
    self.tap do
      self.middleware_from(builder).tap do |middleware|
        container['http.middleware'] = middleware.register
      end

      resolve(:router).yield_self do |router|
        builder.run(router)
      end
    end
  end

  class << self
    # @return [Wolffia]
    def call(path: nil, &block)
      (path || caller_locations.first.path).yield_self do |fp|
        synchronize do
          (@instance ||= self.new(path: fp)).tap do |app|
            block&.call(app)
          end
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

  # Extra elements used to build container.
  #
  # @api private
  #
  # @return [Hash{Synmbol => Object}]
  def extra
    {
      'http.router.loadables': self.routes,
      'http.router.load_path': self.routes_path,
    }
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

  # Register ``__app__`` helper method
  #
  # @return [self]
  def register(method_name = :__app__)
    self.tap do |app|
      ::Kernel.__send__(:define_method, method_name) { app }
    end
  end

  def build_container
    dotenv.then { Container.build(services_path, **extra) }.tap do |container|
      container[:'app.settings'] = Wolffia::Config.new(config_path, self.environment).settings
      self.paths.transform_keys { |k| "#{k}_path".to_sym }.tap do |paths|
        container[:'app.paths'] = paths
        paths.each { |name, path| container[:"app.paths.#{name}"] = path }
      end
    end
  end

  # Resolve an item from the container
  #
  # @param [Mixed] key
  #   The key for the item you wish to resolve
  # @yield
  #   Fallback block to call when a key is missing. Its result will be returned
  # @yieldparam [Mixed] key Missing key
  #
  # @return [Mixed]
  #
  # @api public
  def resolve(key, &block)
    container.resolve(key, &block)
  end

  # Make a middleware from given builder.
  #
  # @api private
  #
  # @param [Rack::Builder]
  def middleware_from(builder)
    Wolffia::HTTP::Middleware.new(builder, container, load_path: middlewares_path, loadables: self.middlewares)
  end
end
