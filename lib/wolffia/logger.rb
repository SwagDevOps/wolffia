# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../wolffia'

# Simple (file based) logger.
class Wolffia::Logger
  include(::Wolffia::Mixins::Autoloaded).autoloaded(self.binding)
  include(::Wolffia::Mixins::Injectable)
  include(::Wolffia::Mixins::Configurable)

  autoload(:JSON, 'json')
  autoload(:FileUtils, 'fileutils')
  autoload(:Logger, 'logger')
  autoload(:Pathname, 'pathname')

  # Default name for the log file.
  #
  # @api private
  DEFAULT_NAME = :messages

  # @!attribute [r] env
  #   @!visibility protected
  #   @api private
  #   @return [Wolffia::Environement]
  auto_inject(env: 'app.env')

  # @!attribute [r] storage_path
  #   @!visibility protected
  #   @api private
  #   @return [Pathname]
  auto_inject(storage_path: 'app.paths.storage_path')

  def initialize(*, **injection, &block)
    super(**injection)
    @pid = Process.pid

    self.configurable do
      setting(:name, default: DEFAULT_NAME)
      setting(:directory, default: storage_path.join('logs', env))
    end.configure(&block).freeze
  end

  # @param [String|Exception] message
  # @param [Object, nil] context
  def debug(message, context = nil)
    log(:DEBUG, message, context)
  end

  # @param [String|Exception] message
  # @param [Object, nil] context
  def info(message, context = nil)
    log(:INFO, message, context)
  end

  # @param [String|Exception] message
  # @param [Object, nil] context
  def warn(message, context = nil)
    log(:WARN, message, context)
  end

  # @param [String|Exception] message
  # @param [Object, nil] context
  def error(message, context = nil)
    log(:ERROR, message, context)
  end

  # @param [String|Exception] message
  # @param [Object. nil] context
  def fatal(message, context = nil)
    log(:FATAL, message, context)
  end

  # @param [String] message
  # @param [Object, nil] context
  def unknown(message, context = nil)
    log(:UNKNOWN, message, context)
  end

  protected

  # @return [Integer]
  attr_reader :pid

  # @return [Symbol]
  def name
    self.config.name.to_sym
  end

  # @return [Pathname]
  def directory
    Pathname.new(self.config.directory).dup
  end

  # @api private
  #
  # @return [Module<FileUtils>]
  def fs
    FileUtils
  end

  # @return [Pathname]
  def file
    # noinspection RubyMismatchedReturnType
    [
      name,
      Time.now.strftime('%Y-%m-%d'),
    ].map(&:to_s).join('.').then do |fname|
      directory.join("#{fname}.log")
    end
  end

  # Create file and directories, and return filepath.
  #
  # @return [Pathname]
  def file!
    self.file.tap do |file|
      fs.mkdir_p(file.dirname)
      fs.touch(file, mtime: nil)
    end
  end

  # @api private
  #
  # @return [Logger]
  def logger
    Logger.new(file!, formatter: self.formatter)
  end

  # @api private
  #
  # @return [Proc]
  def formatter
    proc do |severity, datetime, _progname, message|
      date = datetime.strftime('%Y-%m-%dT%H:%M:%S.%3N')

      "#{date} #{severity[0..0]}[#{pid}]: #{message}\n"
    end
  end

  # @api private
  #
  # @param [Symbol] severity
  # @param [String|Exception] message
  # @param [Object, nil] context
  def log(severity, message, context = nil)
    thread do
      ::Wolffia::Logger::Loggable.new(severity: severity, message: message, context: context).then do |loggable|
        loggable.lines.map { |line| logger.add(loggable.severity, line) }
      end
    end
  end

  # @return [::Thread]
  def thread(&blk)
    ::Thread.new do
      blk.call
    end.tap do |thread|
      thread.report_on_exception = true
      thread.abort_on_exception = false
    end
  end
end
