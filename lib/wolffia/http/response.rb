# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../http'

# Describe an HTTP response
class Wolffia::HTTP::Response
  # @type [String, Array<String>]
  attr_accessor :body

  # @type [Integer]
  attr_accessor :status

  # @type [Hash{Symbol => String}]
  attr_accessor :headers

  def initialize(body, status: 200, headers: {})
    self.body = body
    self.status = status
    self.headers = headers
  end

  def to_a
    [
      status.to_i,
      headers.to_h.transform_keys(&:to_s),
      body.is_a?(Array) ? body : [body]
    ]
  end

  alias to_ary to_a
end
