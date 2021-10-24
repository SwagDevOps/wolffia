# frozen_string_literal: true

# Copyright (C) 2017-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../wolffia'

# Namespace module.
module Wolffia::Cli
  autoload(:Clamp, 'clamp')

  # Represents a shell command.  Each command invocation is a new object.
  # Command options and parameters are represented as attributes
  #
  # Sample of use:
  #
  # ```ruby
  # class Hello < Wolffia::Cli::Command
  #   option "--loud", :flag, "say it loud"
  #   option ["-n", "--iterations"], "N", "say it N times", default: 1 { |s| s ? Integer(s) : 1 }
  #
  # def execute
  #   (@iterations || 1).times { puts "Hello" }
  # end
  #
  # Wolffia::Cli::App.__send__(:subcommands=, { hello: Hello })
  #
  # Wolffia::Cli::App.call
  # ```
  class Command < Clamp::Command
    include(::Wolffia::Mixins::Injectable)

    alias call run

    class << self
      def description
        super || self.name
      end

      def abort(message = nil, status: 1)
        warn(message) unless message.nil?
        exit(status)
      end
    end
  end

  include(::Wolffia::Mixins::Autoloaded).autoloaded(self.binding)
end
