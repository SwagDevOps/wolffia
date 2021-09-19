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
      [:bundleable, :mixins].map { |s| require("#{path}/#{s}") }.then do
        include(::Wolffia::Bundleable)
        include(::Wolffia::Mixins::Autoloaded)
        autoload(:VERSION, "#{path}/version")
      end
    end.autoloaded do |autoloading|
      autoloading.except(:Bundleable, :Mixins, :VERSION)

      {
        HTTP: 'http',
      }.tap { |kwargs| autoloading.with(**kwargs.invert) }
    end
  end

  include(::Wolffia::Mixins::Env)
  include(::Wolffia::HasPaths)
  include(::Wolffia::Inheritance)

  def environment
    container&.resolve(:'app.environment')
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

  # Register appplication startup completion.
  #
  # Register ``__app__`` helper method
  # Register ``container`` on injectable mixin
  #
  # @return [self]
  def register(method_name = :__app__)
    self.tap do |app|
      ::Kernel.__send__(:define_method, method_name) { app }
      ::Wolffia::Mixins::Injectable.register_container(container).freeze
    end
  end

  # rubocop:disable Metrics/AbcSize,Metrics/MethodLength

  def build_container
    volatile = {
      'http.router.loadables': self.routes,
      'http.router.load_path': self.routes_path,
    }

    dotenv.then { Container.build(services_path, volatile) }.tap do |container|
      container[:'app.settings'] = ::Wolffia::Config.new(config_path, self.environment).settings

      self.paths.transform_keys { |k| "#{k}_path".to_sym }.tap do |paths|
        container[:'app.paths'] = paths
        paths.each { |name, path| container[:"app.paths.#{name}"] = path }
      end
    end
  end

  # rubocop:enable Metrics/AbcSize,Metrics/MethodLength

  # Make a middleware from given builder.
  #
  # @api private
  #
  # @param [Rack::Builder] builder
  def middleware_from(builder)
    ::Wolffia::HTTP::Middleware.new(builder, container, load_path: middlewares_path, loadables: self.middlewares)
  end
end
