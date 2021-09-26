# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../container'

# Build an instance of container.
class Wolffia::Container::Builder
  autoload(:Pathname, 'pathname')

  # @api private
  SERVICES_FILE = Pathname.new(__dir__).join('services.rb').freeze

  # @param [String, Pathname] path
  #
  # @param [Hash] volatile volatile values used to build container
  def initialize(path, volatile = {})
    @path = Pathname.new(path.to_s).then { |v| v.directory? ? v.realpath : v }.freeze
    self.volatile = volatile
  end

  # Files used to load services.
  #
  # @return [Array<Pathname>]
  def files
    # noinspection RubyYardReturnMatch
    path.glob('**/*.rb').sort
  end

  # @return [Wolffia::Container]
  def call
    container do |c|
      files.each { |file| c.load_file(file) }
    end
  end

  class << self
    # @return [Wolffia::Container]
    def call(*args)
      self.new(*args).call
    end
  end

  protected

  # @return [Pathname]
  attr_reader :path

  # Volatile varaibles passed to loaded services file.
  #
  # @return [Hash{Symbol => Object}]
  attr_reader :volatile

  # @yieldreturn [Wolffia::Container]
  def container
    ::Wolffia::Container.new.tap do |c|
      c.load_file(SERVICES_FILE, volatile)
      self.volatile = nil

      yield c if block_given?
    end
  end

  # @param [Hash] variables
  def volatile=(variables)
    @volatile = variables.to_h.transform_keys(&:to_sym).freeze
  end
end
