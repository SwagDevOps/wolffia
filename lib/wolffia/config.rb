# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../wolffia'

# Config load.
#
# @see https://github.com/rubyconfig/config
class Wolffia::Config
  autoload(:Config, 'config')
  autoload(:Pathname, 'pathname')

  # @return [Hash]
  attr_reader :setup

  # @return [Pathname]
  attr_reader :path

  # @return [String]
  attr_reader :environement

  # @return [::Config::Options]
  attr_reader :settings

  def initialize(path, environment)
    self.tap do
      @path = Pathname.new(path).freeze
      @environement = environment.to_s.freeze
      @setup = self.class.__send__(:setup).freeze
      @mutex = Mutex.new
    end.configure.tap do
      @settings = Config.load_files(Config.setting_files(self.path, self.environement))
    end.freeze
  end

  class << self
    include Wolffia::Mixins::Env

    # @return [Hash]
    def setup
      {
        use_env: env('CONFIG_USE_ENV', false),
        env_prefix: env('CONFIG_ENV_PREFIX', 'SETTINGS'),
        env_separator: env('CONFIG_ENV_SEPARATOR', '__'),
        env_converter: :downcase,
        env_parse_values: env('CONFIG_ENV_PARSE_VALUES', true),
      }
    end
  end

  protected

  def synchronize(&block)
    @mutex.synchronize { block.call }
  end

  def configure
    self.tap do
      synchronize do
        Config.setup do |config|
          self.setup.each { |k, v| config.public_send("#{k}=", v) }
        end
      end
    end
  end
end
