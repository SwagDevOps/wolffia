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
  include(::Wolffia::Mixins::Autoloaded).autoloaded(self.binding)

  # @return [Pathname]
  attr_reader :load_path

  # @param [Hash] options
  # @param [String] load_path
  # @param [Array<String, Symbol>] loadables
  def initialize(options = {}, load_path:, loadables: [], &blk)
    @load_path = Pathname.new(load_path).freeze
    @loadables = loadables.dup.freeze

    super(options, &blk)
  end

  # @return [Array<Symbol>]
  def loadables
    @loadables.map { |name| Pathname.new(name.to_s).basename.to_s.gsub('.', '/').to_sym }
  end

  # Register the router.
  #
  # @param [Wolffia::Container] container
  #
  # @return [self]
  def register(container: nil)
    self.tap do
      self.loadables.each { |fp| self.load_loadable(fp) }
      self.bind(container) if container
    end
  end

  def get(path, options = {}, &blk)
    super(path, handler_for(options), &blk)
  end

  def post(path, options = {}, &blk)
    super(path, handler_for(options), &blk)
  end

  def put(path, options = {}, &blk)
    super(path, handler_for(options), &blk)
  end

  def patch(path, options = {}, &blk)
    super(path, handler_for(options), &blk)
  end

  def delete(path, options = {}, &blk)
    super(path, handler_for(options), &blk)
  end

  def trace(path, options = {}, &blk)
    super(path, handler_for(options), &blk)
  end

  def options(path, options = {}, &blk)
    super(path, handler_for(options), &blk)
  end

  def root(options = {}, &blk)
    super(handler_for(options), &blk)
  end

  def redirect(path, options = {}, &blk)
    super(path, handler_for(options), &blk)
  end

  # Load routes from given file.
  #
  # @param [String] filepath
  #
  # @return [self]
  def load_file(filepath)
    Pathname.new(filepath).realpath.tap { |file| self.instance_eval(file.read, file.to_s, 1) }
  end

  # Bind given container
  #
  # @param [Wolffia::Container]
  def bind(container)
    self.tap do
      unless container.keys.empty?
        self.controllers.to_h.each_key { |klass| self.controllers[klass] = self.make(klass) }
      end
    end
  end

  protected

  # Load routes from given file.
  #
  # @param [String, Symbol, nil] name
  #
  # @return [self]
  def load_loadable(name)
    self.tap do
      return self unless name

      self.load_path.join("#{name}.rb").yield_self do |file|
        self.load_file(file)
      end
    end
  end

  def controllers
    @controllers ||= ::Concurrent::Hash.new
  end

  # Get an instance for given controller class.
  #
  # @param [Class<Wolffia::HTTP::Controller>] controller
  #
  # @return [Wolffia::HTTP::Controller]
  def instance_for(controller)
    # @type [Wolffia::HTTP::Controller] instance
    self.controllers[controller] ||= make(controller)
  end

  # Make a instance of controller from given class.
  #
  # @param [Class] controller
  #
  # @return [Wolffia::HTTP::Controller]
  def make(controller)
    controller.new.tap do |instance|
      # Ensure actions are indexed by symbols
      instance.actions.transform_keys(&:to_sym).yield_self do |actions|
        instance.singleton_class.__send__(:define_method, :actions) { actions }
      end
    end
  end

  def handler_for(options)
    lambda do |controler|
      self.instance_for(controler)
    end.then { |resolver| HandlerBuilder.new(resolver).call(options) }
  end
end
