# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../middleware'

# Middleware loader built on top of Rack.
#
# @abstract
class Wolffia::HTTP::Middleware::Loader
  include(::Wolffia::Mixins::Injectable)

  # rubocop:disable Lint/UnusedMethodArgument

  # Load middleware on given builder.
  #
  # @abstract
  # @param [Rack::Builder] builder
  def call(builder)
    nil
  end
  # rubocop:enable Lint/UnusedMethodArgument
end
