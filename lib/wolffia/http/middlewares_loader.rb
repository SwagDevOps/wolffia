# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../http'

# Describe aa middlewares loader build on top of ``Rack::Builder``.
class Wolffia::HTTP::MiddlewaresLoader
  autoload(:Pathname, 'pathname')

  # @return [Array]
  attr_reader :loadables

  # @param [Rack::Builder] builder
  # @param [Wolffia::Container] container
  # @param [String, Pathname] load_path
  def initialize(builder, container, load_path:, loadables: [])
    @builder = self.make_builder(builder, container)
    self.loadables = loadables
    @load_path = Pathname.new(load_path).freeze
  end

  def call
    self.tap do
      self.loadables.map { |name| use(name) }
    end
  end

  def load_file(filepath)
    Pathname.new(filepath).realpath.tap do |file|
      builder.instance_eval(file.read, file.to_s, 1).tap do |middleware|
        pp(middleware)
      end
    end
  end

  alias register call

  alias to_a loadables

  protected

  # @return [Rack::Builder]
  attr_reader :builder

  # Get path where middlewares are loaded.
  #
  # @return [Pathname]
  attr_reader :load_path

  # Load middlware loading from given name.
  #
  # @param [String] name
  #
  # @return [self]
  def use(name)
    self.tap do
      load_path.join("#{name}.rb").yield_self { |file| self.load_file(file) }
    end
  end

  def loadables=(loadables)
    @loadables = loadables.map do |name|
      Pathname.new(name.to_s).basename.to_s.gsub('.', '/').to_sym
    end.freeze
  end

  # @param [Rack::Builder] builder
  # @param [Wolffia::Container] container
  #
  # @return [Rack::Builder]
  def make_builder(builder, container)
    builder.tap do
      builder.singleton_class.__send__(:define_method, :container) { container }
    end
  end
end
