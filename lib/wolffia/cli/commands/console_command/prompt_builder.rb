# frozen_string_literal: true

# Copyright (C) 2017-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../console_command'

# Prompt builder (using pastel).
class Wolffia::Cli::Commands::ConsoleCommand::PromptBuilder
  include(::Wolffia::Mixins::Injectable)

  # @!attribute gems
  #   @visibility protected
  #   @return [Hash{String => Object}]
  auto_inject(gems: 'gem.loaded_specs')

  # @!attribute app
  #   @visibility protected
  #   @return [Wolffia]
  auto_inject(app: 'app.instance')

  # @!attribute environment
  #   @visibility protected
  #   @return [Wolffia::Environment]
  auto_inject(environment: 'app.env')

  # @return [Sring]
  def call(context, nesting, pry_instance, *, sep: nil)
    [
      make_base(context, nesting, pry_instance),
      sep ? "#{sep.rstrip} " : nil,
    ].compact.join
  end

  protected

  def make_base(context, nesting, pry_instance)
    colorize('%<identifier>s(%<environment>s):%<input_ring>s:%<nesting>s' % {
      identifier: context == app ? 'pry' : Pry.view_clip(context),
      environment: environment.to_s,
      input_ring: pry_instance.input_ring.count.to_s.rjust(3, '0'),
      nesting: nesting
    }, context == app ? :cyan : :yellow, :bold)
  end

  # @return [String]
  def colorize(str, *params)
    pastel.nil? ? str : pastel.decorate(*[str].concat(params))
  end

  # Pastel provides independent coloring component for TTY toolkit.
  #
  # @see https://github.com/piotrmurach/pastel
  #
  # @return [Pastel, nil]
  def pastel
    return nil unless gems.key?('pastel')

    autoload(:Pastel, 'pastel').then { Pastel.new }
  end
end
