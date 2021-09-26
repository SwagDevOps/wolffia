# frozen_string_literal: true

require_relative '../helper'

# Provide ``silence_stream`` method.
module Spec::Helper::SilenceStream
  # rubocop:disable Metrics/MethodLength

  # Silences any stream for the duration of the block.
  #
  # @see https://apidock.com/rails/Kernel/silence_stream
  def silence_stream(stream)
    @silence_stream_mutex ||= Mutex.new

    @silence_stream_mutex.synchronize do
      old_stream = stream.dup
      # @formatter:off
      (::RbConfig::CONFIG['host_os'] =~ /mswin|mingw/ ? 'NUL:' : '/dev/null')
        .tap { |stream_null| stream.reopen(stream_null) }
      # @formatter:on
      stream.sync = true
      yield
    ensure
      stream.reopen(old_stream)
      old_stream.close
    end
  end
  # rubocop:enable Metrics/MethodLength
end
