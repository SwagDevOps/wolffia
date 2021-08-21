# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../mixins'

# Provide env method.
module Wolffia::Mixins::Env
  autoload(:YAML, 'yaml')

  protected

  def env(key, default = nil)
    ENV.key?(key) ? YAML.safe_load(ENV.fetch(key)) : default
  end
end
