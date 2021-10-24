# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../wolffia' unless defined?(::Wolffia)

# First-class methods to inherit application.
module Wolffia::Inheritance
  # Rack middlewares
  #
  # @return [Array<String, Symbol>]
  def middlewares
    []
  end

  # Routes
  #
  # @return [Array<String, Symbol>]
  def routes
    []
  end

  # Commands available on the CLI.
  #
  # @return [Hash{Symbol => Class<Wolffia::Cli::Command>}]
  def commands
    {
      serve: ::Wolffia::Cli::Commands::ServeCommand,
    }
  end
end
