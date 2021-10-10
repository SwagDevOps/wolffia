# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../middleware'

# Parse middleware file, to extract classes.
class Wolffia::HTTP::Middleware::Parser
  autoload(:Pathname, 'pathname')
  autoload(:Ripper, 'ripper')

  # @api private
  LOADER_CLASS = ::Wolffia::HTTP::Middleware::Loader

  # @param [String, Pathname] filepath
  #
  # @return [Wolffia::HTTP::Middleware::Loader, Proc]
  def parse(filepath)
    get_class(filepath)&.new || loader_for(filepath)
  end

  alias call parse

  class << self
    # Parse given filepath to extract or build a middleware loader.
    #
    # @param [String, Pathname] filepath
    #
    # @return [Wolffia::HTTP::Middleware::Loader, Proc]
    def call(filepath)
      self.new.parse(filepath)
    end
  end

  protected

  # @param [String, Pathname] filepath
  #
  # @return [String]
  def read(filepath)
    (filepath.is_a?(Pathname) ? filepath : Pathname.new(filepath)).read
  end

  # Get classes (as strings) defined in file.
  #
  # @param [String, Pathname] filepath
  #
  # @return [Array<String>]
  def extract_classes(filepath)
    Ripper.sexp(read(filepath)).keep_if do |v|
      v.is_a?(::Array) and v[0].is_a?(::Array) and v[0].size > 1 and v[0][0] == :class
    end.map do |v|
      v[0][1].flatten.keep_if { |s| s.is_a?(String) }.join('::')
    end
  end

  # Load classes defined in file.
  #
  # @param [String, Pathname] filepath
  #
  # @return [Array<Class>]
  def get_classes(filepath)
    extract_classes(filepath).map do |klass_name|
      require filepath.to_s

      instance_eval(klass_name.to_s)
    end.keep_if { |v| v.is_a?(::Class) }
  end

  # Get first inherited class defined in file.
  #
  # @param [String, Pathname] filepath
  #
  # @return [Class<Wolffia::HTTP::Middleware::Loader>, nil]
  def get_class(filepath)
    nil.tap do
      get_classes(filepath).each do |klass|
        return klass if klass.ancestors.include?(LOADER_CLASS)
      end
    end
  end

  # @api private
  # Build a generic loader for given file.
  #
  # @param [String] filepath
  #
  # @return [Proc]
  def loader_for(filepath)
    file = Pathname.new(filepath)

    lambda do |builder|
      builder.instance_eval(file.read, file.to_s, 1)
    end
  end
end
