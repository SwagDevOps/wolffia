# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../container'

# Build an instance of container.
class Wolffia::Container::Builder
  autoload(:Pathname, 'pathname')
  include(Wolffia::Mixins::Env)

  # @param [String, Pathname] base_dir
  def initialize(base_dir, **extra)
    @base_dir = Pathname.new(base_dir.to_s).realpath
    @extra = extra.transform_keys(&:to_sym)
  end

  # @return [Symbol]
  def environment
    env('APP_ENV', 'development').to_sym
  end

  # Files used to load services.
  #
  # @return [Array<Pathname>]
  def files
    # noinspection RubyYardReturnMatch
    self.base_dir.glob('**/*.rb').sort
  end

  # @return [String]
  def to_path
    self.file.to_path
  end

  # @return [Wolffia::Container]
  def call
    container do |c|
      self.extra.each { |k, v| c[k] = v }
      c.populate(:router) { make_router(c).register }
      files.each { |file| c.load_file(file) }
      c[:router] = c.resolve(:router).tap { |router| router.__send__(:injector=, c.injector) }
    end
  end

  class << self
    # @return [Wolffia::Container]
    def call(...)
      self.new(...).call
    end
  end

  protected

  # @return [Pathname]
  attr_reader :base_dir

  attr_reader :extra

  # @yieldreturn [Wolffia::Container]
  def container
    Wolffia::Container.new.tap do |c|
      c[:'app.base_dir'] = self.base_dir
      c[:'app.environment'] = self.environment
      c[:'app.settings'] = Wolffia::Config.new(self.base_dir, self.environment).settings
      c[:json] = json

      yield c if block_given?
    end
  end

  # @api private
  #
  # @return [Proc]
  def json
    lambda do
      (require 'json').yield_self { JSON }
    end
  end

  # @param [Wolffia::Container] container
  #
  # @return [Wolffia::HTTP::Router]
  def make_router(container)
    { load_path: container[:'http.router.load_path'], loadables: container[:'http.router.loadables'] }
      .then { |options| ::Wolffia::HTTP::Router.new(**options) }
  end
end
