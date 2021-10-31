# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../app' # unless defined?(::Wolffia)

# Add cli method
module Wolffia::App::Cli
  # Commands available on the CLI.
  #
  # @return [Hash{Symbol => Class<Wolffia::Cli::Command>}]
  def commands
    {
      serve: :ServeCommand,
      console: (defined?(:Gem) and Gem.loaded_specs.key?('pry')) ? :ConsoleCommand : nil
    }.compact.transform_values { |v| ::Wolffia::Cli::Commands.const_get(v) }.sort.to_h
  end

  # @return [Wolffia::Cli::App]
  def cli
    container[:cli]
  end
end
