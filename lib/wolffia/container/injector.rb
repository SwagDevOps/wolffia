# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../container'
require 'dry/auto_inject'

# Remove some troubles due to BasicObject
#
# @see Dry.AutoInject
# @see https://dry-rb.org/gems/dry-auto_inject/0.6/basic-usage/#creating-an-injector
class Wolffia::Container::Injector < Dry::AutoInject::Builder
  def class
    self.instance_eval('class << self; self end', __FILE__, __LINE__).superclass
  end

  def nil?
    false
  end

  def tap
    yield(self)
    self
  end

  def object_id
    __id__
  end

  def inspect
    "#<#{self.class}:#{object_id}>"
  end
end
