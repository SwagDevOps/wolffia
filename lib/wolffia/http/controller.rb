# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../http'

# @abstract
class Wolffia::HTTP::Controller
  include Wolffia::Mixins::Injectable

  # @return [Hash{Symbol => Proc}]
  def actions
    {}
  end

  def headers
    {}
  end

  protected

  def response(body, status: 200, headers: {})
    Wolffia::HTTP::Response.new(body).tap do |response|
      response.status = status
      response.headers = self.headers.merge(headers)
    end
  end
end
