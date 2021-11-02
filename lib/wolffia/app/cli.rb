# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../app'

# Add cli method
module Wolffia::App::Cli
  include(::Wolffia::Mixins::Autoloaded).autoloaded(self.binding)

  # Commands available on the CLI.
  #
  # @return [Hash{Symbol => Class<Wolffia::Cli::Command>}]
  def commands
    Commands.to_h
  end

  # @return [Wolffia::Cli::App]
  def cli
    container.load_file("#{__dir__}/cli/services.rb").then do
      container[:cli]
    end
  end
end
