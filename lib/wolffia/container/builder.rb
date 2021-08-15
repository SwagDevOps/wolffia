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
  def initialize(base_dir)
    @base_dir = Pathname.new(base_dir.to_s).realpath
  end

  # @return [Symbol]
  def environment
    env('APP_ENV', 'development').to_sym
  end

  # File used to load services.
  #
  # @return [Pathname]
  def file
    # noinspection RubyYardReturnMatch
    self.base_dir.join('container/services.rb')
  end

  # @return [String]
  def to_path
    self.file.to_path
  end

  # @return [Wolffia::Container]
  def call
    container do |c|
      c.populate(:router) { Wolffia::HTTP::Router.new.load_file(self.base_dir.join('routes/web.rb')) }
      c.load_file(self.file)
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

  # @yieldreturn [Wolffia::Container]
  def container
    Wolffia::Container.new.tap do |c|
      c[:'app.base_dir'] = self.base_dir
      c[:'app.environment'] = self.environment
      c[:'app.settings'] = Wolffia::Config.new(self.base_dir, self.environment).settings
      c[:json] = json_loader

      yield c if block_given?
    end
  end

  # @api private
  # @return [Proc]
  def json_loader
    lambda do
      (require 'json').yield_self { JSON }
    end
  end
end
