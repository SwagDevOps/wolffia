# frozen_string_literal: true

# Copyright (C) 2017-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../console'

# Loader for configuration file(s).
class Wolffia::App::Cli::Commands::Console::ConfigLoader
  autoload(:Pathname, 'pathname')

  # @param [Pathname] file
  def initialize(file, variables = {})
    self.tap do
      @file = Pathname.new(file).realpath.freeze
      @variables = variables.transform_keys(&:to_sym).transform_values(&:freeze).freeze
    end.freeze
  end

  def call
    config.instance_eval(file.read, file.to_s, 1)
  end

  protected

  # @return [Pathname]
  attr_reader :file

  # @return [Hash]
  attr_reader :variables

  # @return [Pry::Config]
  def config
    (require 'pry').then { ::Pry.config }.tap do |config|
      variables.transform_keys(&:to_sym).each do |k, _|
        raise "#{config.class}##{k} method is already defined" if config.respond_to?(k)
      end.reject { |k, _| config.respond_to?(k) }.each do |k, v|
        config.singleton_class.__send__(:define_method, k) { v }
      end
    end
  end
end
