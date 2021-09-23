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
  include(::Wolffia::Mixins::Env)

  # @param [String, Pathname] path
  #
  # @param [Hash] volatile volatile values used to build container
  def initialize(path, volatile = {})
    @path = Pathname.new(path.to_s).then { |v| v.directory? ? v.realpath : v }.freeze
    @volatile = volatile.transform_keys(&:to_sym).freeze

    self.freeze
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
    path.glob('**/*.rb').sort
  end

  # @return [String]
  def to_path
    self.path.to_path
  end

  # @return [Wolffia::Container]
  def call
    container do |c|
      c.populate(:'http.router') { router.register }
      files.each { |file| c.load_file(file) }
      c[:'http.router'] = c.resolve(:'http.router').tap { |router| router.bind(c) }
    end
  end

  class << self
    # @return [Wolffia::Container]
    def call(*args)
      self.new(*args).call
    end
  end

  protected

  # @return [Pathname]
  attr_reader :path

  # @return [Hash{Symbol => Object}]
  attr_reader :volatile

  # @yieldreturn [Wolffia::Container]
  def container
    ::Wolffia::Container.new.tap do |c|
      c[:'app.environment'] = self.environment
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

  # @return [Wolffia::HTTP::Router]
  def router
    { load_path: volatile.fetch(:'http.router.load_path'), loadables: volatile.fetch(:'http.router.loadables') }
      .then { |options| ::Wolffia::HTTP::Router.new(**options) }
  end
end
