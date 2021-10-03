# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../wolffia' unless defined?(::Wolffia)

# Define some paths where bootstrap elements and config are stored.
module Wolffia::HasPaths
  # @return [Pathname]
  def bootstrap_path
    self.base_path.join('bootstrap')
  end

  # Fet path to where config files are stored.
  #
  # Config helps you easily manage environment specific settings.
  #
  # @see https://github.com/rubyconfig/config
  #
  # @return [Pathname]
  def config_path
    self.base_path.join('config')
  end

  # Get path to the route declarations.
  #
  # @return [Pathname]
  def routes_path
    # noinspection RubyMismatchedReturnType
    self.bootstrap_path.join('routes')
  end

  # Get path to the middleware declarations.
  #
  # @return [Pathname]
  def middlewares_path
    # noinspection RubyMismatchedReturnType
    self.bootstrap_path.join('middlewares')
  end

  # Get path to the commands declarations.
  #
  # @return [Pathname]
  def commands_path
    # noinspection RubyMismatchedReturnType
    self.bootstrap_path.join('commands')
  end

  # Get path where services definitions are stored.
  #
  # @see https://github.com/dry-rb/dry-container
  #
  # @return [Pathname]
  def services_path
    # noinspection RubyMismatchedReturnType
    self.bootstrap_path.join('services')
  end

  # Get all defined paths.
  #
  # @return [Hash{Symbol => Pathname}]
  def paths
    self.methods
        .select { |m| m[/.+_path$/] }
        .map { |m| [m.to_s.gsub(/_path$/, '').to_sym, __send__(m)] }
        .sort
        .to_h
        .transform_values(&:freeze)
  end
end
