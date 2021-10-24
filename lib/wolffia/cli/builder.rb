# frozen_string_literal: true

# Copyright (C) 2017-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../cli'

# Builder for CLI App.
class Wolffia::Cli::Builder
  class << self
    # @param [Hash{Symbol => Class<Wolffia::Cli::Command>}] commands
    #
    # @return [Class<Wolffia::Cli::App>]
    def call(commands)
      Class.new(::Wolffia::Cli::App)
           .tap { |klass| klass.__send__(:subcommands=, commands) }
    end
  end
end
