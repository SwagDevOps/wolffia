# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../wolffia'

# Simple logger
class Wolffia::Logger
  include(::Wolffia::Mixins::Injectable)
  autoload(:JSON, 'json')
  autoload(:FileUtils, 'fileutils')
  autoload(:Logger, 'logger')
  autoload(:Pathname, 'pathname')

  # @!attribute env
  #   @!visibility protected
  #   @return [Wolffia::Environement]
  auto_inject(env: 'app.env')

  # @!attribute storage_path
  #   @!visibility protected
  #   @return [Pathname]
  auto_inject(storage_path: 'app.paths.storage_path')

  def initialize(directory: nil, **injection)
    super(**injection)

    @pid = Process.pid
    @directory = directory ? Pathname.new(directory) : storage_path.join('log', env)
  end

  # @param [String] message
  # @param [Object, nil] context
  #
  # @return [Array<String>]
  def debug(message, context = nil)
    add(:DEBUG, message, context)
  end

  # @param [String] message
  # @param [Object, nil] context
  #
  # @return [Array<String>]
  def info(message, context = nil)
    add(:INFO, message, context)
  end

  # @param [String] message
  # @param [Object, nil] context
  #
  # @return [Array<String>]
  def warn(message, context = nil)
    add(:WARN, message, context)
  end

  # @param [String] message
  # @param [Object, nil] context
  #
  # @return [Array<String>]
  def error(message, context = nil)
    add(:ERROR, message, context)
  end

  # @param [String] message
  # @param [Object. nil] context
  #
  # @return [Array<String>]
  def fatal(message, context = nil)
    add(:FATAL, message, context)
  end

  # @param [String] message
  # @param [Object, nil] context
  #
  # @return [Array<String>]
  def unknown(message, context = nil)
    add(:UNKNOWN, message, context)
  end

  protected

  # @return [Pathname]
  attr_reader :directory

  # @return [Integer]
  attr_reader :pid

  # @return [Module<FileUtils>]
  def fs
    FileUtils
  end

  # @return [Pathname]
  def file
    # noinspection RubyMismatchedReturnType
    [
      'messages',
      Time.now.strftime('%Y-%m-%d'),
    ].join('.').then do |fname|
      directory.join("#{fname}.log")
    end
  end

  def file!
    self.file.tap do |file|
      fs.mkdir_p(file.dirname)
      fs.touch(file, mtime: nil)
    end
  end

  # @return [Logger]
  def logger
    Logger.new(file!).tap do |logger|
      logger.formatter = self.formatter
    end
  end

  # @return [Proc]
  def formatter
    proc do |severity, datetime, _progname, message|
      date = datetime.strftime('%Y-%m-%dT%H:%M:%S.%3N')

      "#{date} #{severity[0..0]}[#{pid}]: #{message}\n"
    end
  end

  # @param [String] message
  # @param [Object, nil] context
  #
  # @return [Array<String>]
  def add(severity, message, context = nil)
    message.to_s.lines.map do |line|
      line.tap do
        ::Thread.new do
          line = "#{line} #{JSON.generate(context)}" unless context.nil?

          logger.add(Logger.const_get(severity), line.strip)
        end
      end
    end
  end
end
