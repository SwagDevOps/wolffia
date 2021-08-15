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

  {
    Bundleable: 'bundleable',
    Concurrent: 'concurrent',
    Config: 'config',
    Container: 'container',
    Dotenv: 'dotenv',
    HTTP: 'http',
    Mixins: 'mixins',
    VERSION: 'version',
  }.each { |s, fp| autoload(s, "#{__dir__}/wolffia/#{fp}") }

  include(Bundleable)
  include(Wolffia::Mixins::Env)

  def environment
    container&.resolve(:'app.environment')
  end

  # @return [Wolffia::Container::Injector, nil]
  def injector
    @container&.injector
  end

  # @param [Rack::Builder] builder
  def run(builder)
    self.tap do
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
      (@mutex ||= Mutex.new).synchronize { block.call }
    end
  end

  protected

  # @return [Pathname]
  attr_reader :path

  # @return [Wolffia::Container]
  attr_accessor :container

  def initialize(path: nil)
    Wolffia::Concurrent.call

    self.path = path
    self.container = dotenv.yield_self { Wolffia::Container.build(self.path) }

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
    Wolffia::Dotenv.new(path: self.path).call
  end

  # Register ``__app__`` helper method
  #
  # @return [self]
  def register(method_name = :__app__)
    self.tap do |app|
      Kernel.__send__(:define_method, method_name) { app }
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
end
