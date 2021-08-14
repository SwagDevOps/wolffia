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

  def initialize(path: Dir.pwd, filename: '.env')
    self.tap do
      @path = Pathname.new(path)
      @filename = filename
    end.freeze
  end

  def to_path
    self.path.join(self.filename)
  end

  alias to_s to_path

  def call
    Dotenv.load(self.to_path)
  end

  protected

  # @return [Pathname]
  attr_reader :path

  attr_reader :filename
end
