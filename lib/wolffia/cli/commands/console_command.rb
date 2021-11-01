# frozen_string_literal: true

# Copyright (C) 2017-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../commands'

# Provide console session (based on Pry).
#
# @see https://github.com/pry/pry
class Wolffia::Cli::Commands::ConsoleCommand < ::Wolffia::Cli::Command
  self.description = 'Start a console session'

  autoload(:FileUtils, 'fileutils')

  autoload(:Pathname, 'pathname')

  # @type [::Autoloaded::Autoloader] autoloader
  include(::Wolffia::Mixins::Autoloaded).autoloaded(self.binding) do |autoloader|
    autoloader.except(:Config)
  end

  # @!attribute app
  #   @!visibility protected
  #   @return [Wolffia]
  auto_inject(app: 'app.instance')

  # @!attribute base_path
  #   @!visibility protected
  #   @return [Pathname]
  auto_inject(base_path: 'app.paths.base_path')

  def execute
    with_pry do
      app.instance_eval do
        # @see https://github.com/pry/pry/issues/1275
        at_exit { system('stty echo') }

        ::Pry.start(binding, { quiet: true })
      end
    end
  end

  # Get path to local config.
  #
  # @return [Pathname]
  def config_path
    # noinspection RubyMismatchedReturnType
    base_path.join('.pry')
  end

  # @return [Array<Pathname>]
  def config_files
    # noinspection RubyMismatchedReturnType
    [
      Pathname.new(__FILE__.gsub(/\.rb$/, '')).join('config.rb'),
      config_path.join('config.rb')
    ].keep_if { |f| f.is_a?(Pathname) and f.exist? and f.file? and f.readable? }
  end

  protected

  # Variables passed to config file (as methods).
  #
  # @return [Hash{Symbol => Object}]
  def config_variables
    {
      config_path: self.config_path,
      prompt_builder: PromptBuilder.new,
    }
  end

  # Execute given block with a pry context, loading configurations.
  def with_pry(&block)
    (require 'pry').then do
      FileUtils.mkdir_p(config_path)
      self.config_files.each { |file| ConfigLoader.new(file, config_variables).call }

      block.call
    end
  end
end
