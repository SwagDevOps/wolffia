# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../wolffia'

# Describe a dotenv loader.
#
# Thin wrapper on top of ``bkeepers/dotenv``.
class Wolffia::Dotenv
  autoload(:Pathname, 'pathname')
  autoload(:Dotenv, 'dotenv')
  autoload(:DotenvValidator, 'dotenv_validator')

  def initialize(path: Dir.pwd, filename: '.env')
    self.tap do
      @path = Pathname.new(path)
      @filename = filename
    end.freeze
  end

  # @return [String]
  def to_path
    self.path.join(self.filename).to_path
  end

  alias to_s to_path

  # Load dotenv file and validate env.
  #
  # @raise [RuntimeError] for missing environment variables
  def call
    Dotenv.load(self.to_path).tap { validator.check! }
  end

  protected

  # @return [Pathname]
  attr_reader :path

  # @return [String]
  attr_reader :filename

  # Get env validator.
  #
  # @see https://github.com/fastruby/dotenv_validator
  #
  # @return [Module<DotenvValidator>]
  def validator
    DotenvValidator.tap do |klass|
      self.path.yield_self do |path|
        klass.singleton_class.__send__(:define_method, :root) { path }
      end
    end
  end
end
