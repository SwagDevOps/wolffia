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

  # @!attribute app
  #   @!visibility protected
  #   @return [Wolffia]
  auto_inject(app: 'app.instance')

  def execute
    options.then do |options|
      with_pry do
        app.instance_eval { ::Pry.start(binding, options) }
      end
    end
  end

  protected

  def options
    { quiet: true }
  end

  def prompt
    proc do |_context, nesting, pry_instance, _sep|
      "pry(#{app.environment}):#{pry_instance.input_ring.count.to_s.rjust(3, '0')}:#{nesting}"
    end
  end

  def with_pry(&block)
    (require 'pry').then do
      [
        proc { |*args| "#{prompt.call(*args)}> " },
        proc { |*args| "#{prompt.call(*args)}* " }
      ].then do |prompts|
        ::Pry.config.prompt = ::Pry::Prompt.new('custom', 'custom prompt', prompts)
      end

      block.call
    end
  end
end
