# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../wolffia'

# Define some paths where different bootstrap element are retrieved.
module Wolffia::HasPaths
  # @return [Pathname]
  def bootstrap_path
    self.base_dir.join('bootstrap')
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

  def services_path
    # noinspection RubyMismatchedReturnType
    self.bootstrap_path.join('services')
  end
end
