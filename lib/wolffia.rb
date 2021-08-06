# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

$LOAD_PATH.unshift(__dir__)

# Entrypoint
class Wolffia
  autoload(:Pathname, 'pathname')

  {
    Bundleable: 'bundleable',
    Concurrent: 'concurrent',
    Container: 'container',
    HTTP: 'http',
    Mixins: 'mixins',
    VERSION: 'version',
  }.each { |s, fp| autoload(s, "#{__dir__}/wolffia/#{fp}") }

  include(Bundleable)

  # @return [Pathname]
  attr_reader :path

  # @return [Wolffia::Container]
  attr_writer :container

  # @return [Wolffia::Container]
  def container
    @container ||= lambda do
      Wolffia::Container.new.tap do |c|
        c.register(:base_dir, self.path)
        c.populate(:router) { Wolffia::HTTP::Router.new.load_file(self.path.join('routes/web.rb')) }
        c.load_file(self.path.join('container/services.rb'))
        c[:router] = c.resolve(:router).tap { |router| router.__send__(:injector=, c.injector) }
      end
    end.call
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
        synchronize { @instance ||= self.new(path: fp) }
        block&.call(@instance)

        return @instance
      end
    end

    # @return [Wolffia]
    def instance
      caller_locations.first.path.yield_self do |path|
        synchronize { @instance ||= self.new(path: path) }
      end
    end

    # @return [Wolffia::Container::Injector, nil]
    def injector
      instance ? instance.container.injector : nil
    end

    protected :new

    protected

    def synchronize(&block)
      (@mutex ||= Mutex.new).synchronize { block.call }
    end
  end

  protected

  def initialize(path: nil)
    Wolffia::Concurrent.call

    self.path = path
    self.container = self.container
  end

  def path=(path)
    Pathname.new(path).yield_self { |fp| fp.directory? ? fp : fp.dirname }.realpath.freeze.tap do |dir|
      @path = dir
    end
  end
end
