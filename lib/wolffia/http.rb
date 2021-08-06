# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../wolffia'

# Module namesapce
module Wolffia::HTTP
  {
    Controller: 'controller',
    Response: 'response',
    Router: 'router',
  }.each { |s, fp| autoload(s, "#{__dir__}/http/#{fp}") }
end
