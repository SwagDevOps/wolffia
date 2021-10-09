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

  # @return [Wolffia::HTTP::Middleware::Loader, Proc]
  def parse(filepath)
    get_class(filepath)&.new || loader_from(file: Pathname.new(filepath))
  end

  class << self
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

  # @param [String, Pathname] filepath
  #
  # @return [Array<String>]
  def get_classes(filepath)
    Ripper.sexp(read(filepath))
          .keep_if { |v| v.is_a?(::Array) and v[0].is_a?(::Array) }
          .map { |v| [v[0][0], v[0][1]] }
          .keep_if { |k, _| k == :class }
          .map { |_, v| v.flatten.keep_if { |s| s.is_a?(String) }.join('::') }
  end

  # @param [String, Pathname] filepath
  #
  # @return [Class<Wolffia::HTTP::Middleware::Loader>, nil]
  def get_class(filepath)
    nil.tap do
      get_classes(filepath).each do |klass_name|
        require filepath.to_s

        instance_eval(klass_name.to_s).then do |klass|
          return klass if klass.ancestors.include?(::Wolffia::HTTP::Middleware)
        end
      end
    end
  end

  # @return [Proc]
  def loader_from(file:)
    lambda do |builder|
      builder.instance_eval(file.read, file.to_s, 1)
    end
  end
end
