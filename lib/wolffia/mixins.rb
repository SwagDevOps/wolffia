# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../wolffia'

# Module namesapce
module Wolffia::Mixins
  require_relative './mixins/autoloaded'

  # @type [::Autoloaded::Autoloader] autoloader
  include(::Wolffia::Mixins::Autoloaded).autoloaded(self.binding) do |autoloader|
    autoloader.except(:Autoloaded)
  end
end
