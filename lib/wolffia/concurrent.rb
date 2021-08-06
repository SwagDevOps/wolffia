# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../wolffia'

# Simple loader for ``concurrent-ruby``
#
# @see http://concurrent-ruby.com/
# @see https://github.com/ruby-concurrency/concurrent-ruby
module Wolffia::Concurrent
  class << self
    def call(name = nil)
      # noinspection RubyResolve
      require ['concurrent', name].compact.join('/')
    end
  end
end
