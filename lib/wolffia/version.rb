# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

Wolffia.instance_eval do
  self.remove_const(:VERSION)

  require('kamaze/version')
    .then { self.const_set(:VERSION, ::Kamaze::Version.new.freeze) }
end
