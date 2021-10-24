# frozen_string_literal: true

# Copyright (C) 2017-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../cli'

# Describe CLI Application.
class Wolffia::Cli::App < Wolffia::Cli::Command
  class << self
    def start(arguments: ARGV, context: nil)
      self.run(nil, arguments.dup, context)
    end

    alias call start

    # @return [Hash{Symbol => Class<Wolffia::Cli::Command>}]
    def subcommands
      (@subcommands ||= {}).dup
    end

    protected

    def run(invocation_path = nil, arguments = nil, context = nil)
      new(invocation_path, context).run(arguments)
    rescue Clamp::UsageError => e
      abort(["ERROR: #{e.message}", nil, "See: '#{e.command.invocation_path} --help'"].join("\n"))
    rescue Clamp::HelpWanted => e
      abort(e.command.help, status: 22)
    rescue Clamp::ExecutionError => e
      abort("ERROR: #{e.message}", status: e.status)
    rescue SignalException => e
      abort(status: 128 + e.signo)
    end

    def new(invocation_path = nil, context = nil)
      subcommands.each { |name, command| add_command(command, name: name) }
      super
    end

    # @param [Hash{Symbol => Class<Wolffia::Cli::Command>}] subcommands
    def subcommands=(subcommands)
      @subcommands = subcommands.dup
    end

    # @param [Class<Command>] command
    def add_command(command, name:)
      [name.to_s, command.description, command].tap do |args|
        args[1] = args[1].to_s.empty? ? command.name : args[1]
      end.then do |args|
        subcommand(*args)
      end
    end
  end
end
