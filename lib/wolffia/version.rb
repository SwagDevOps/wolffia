# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../wolffia' unless defined?(::Wolffia)

::Wolffia.instance_eval do
  lambda do
    require('kamaze/version').then { self.const_set(:VERSION, ::Kamaze::Version.new.freeze) }
  end.then do |f|
    f.call unless self.constants(false).include?(:VERSION)
  end
end
