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
  include(Wolffia::Autoloaded).autoloaded(self.binding)
  include Wolffia::HTTP::Router::HasHandler

  # @return [Pathname]
  attr_reader :load_path

  # @param [String] load_path
  # @param [Array<String, Symbol>]
  def initialize(options = {}, load_path:, loadables: [], &blk)
    @load_path = Pathname.new(load_path)
    @loadables = loadables
    super(options, &blk)
  end

  # @return [Array<Symbol>]
  def loadables
    @loadables.map { |name| Pathname.new(name.to_s).basename.to_s.gsub('.', '/').to_sym }
  end

  def register
    self.tap do
      self.loadables.each do |fp|
        self.load_loadable(fp)
      end
    end
  end

  def get(path, options = {}, &blk)
    super(path, handleable(options), &blk)
  end

  def post(path, options = {}, &blk)
    super(path, handleable(options), &blk)
  end

  def put(path, options = {}, &blk)
    super(path, handleable(options), &blk)
  end

  def patch(path, options = {}, &blk)
    super(path, handleable(options), &blk)
  end

  def delete(path, options = {}, &blk)
    super(path, handleable(options), &blk)
  end

  def trace(path, options = {}, &blk)
    super(path, handleable(options), &blk)
  end

  def options(path, options = {}, &blk)
    super(path, handleable(options), &blk)
  end

  def root(options = {}, &blk)
    super(handleable(options), &blk)
  end

  def redirect(path, options = {}, &blk)
    super(path, handleable(options), &blk)
  end

  # Load routes from given file.
  #
  # @param [String] filepath
  #
  # @return [self]
  def load_file(filepath)
    Pathname.new(filepath).realpath.tap { |file| self.instance_eval(file.read, file.to_s, 1) }
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

  # @return [Wolffia::Container::Injector]
  attr_reader :injector

  def controllers
    @controllers ||= Concurrent::Hash.new
  end

  def injector=(injector)
    (@injector = injector).tap do
      self.controllers.to_h.each_key do |klass|
        self.controllers[klass] = self.instance_for(klass)
      end
    end
  end

  # Get an instance for given controller class.
  #
  # @param [Class<Wolffia::HTTP::Controller>] controller
  #
  # @return [Wolffia::HTTP::Controller]
  def instance_for(controller)
    # @type [Wolffia::HTTP::Controller] instance
    self.controllers[controller] ||= controller.tap { |c| c.__send__(:injector=, injector) }.new.tap do |instance|
      instance.actions.yield_self do |actions|
        # Ensure actions are indexed by symbols
        instance.singleton_class.__send__(:define_method, :actions) { actions.transform_keys(&:to_sym) }
      end
    end
  end
end
