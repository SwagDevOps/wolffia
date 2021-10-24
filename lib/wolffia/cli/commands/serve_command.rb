# frozen_string_literal: true

# Copyright (C) 2017-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../commands'

# Start a web server based on rack or rhino.
#
# @see https://github.com/ksylvest/rhino
# @see https://github.com/macournoyer/thin
#
# Sample of use:
#
# ```shell
# ruby www/app.rb serve --server thin
# bundle exec rerun -- www/app.rb serve --server thin
# ```
class Wolffia::Cli::Commands::ServeCommand < ::Wolffia::Cli::Command
  self.description = 'Run a web server (based on rack)'

  # @!attribute app_env
  #   @!visibility protected
  #   @return [Wolffia::Environement]
  auto_inject(app_env: 'app.env')

  # @!attribute base_path
  #   @!visibility protected
  #   @return [Pathname]
  auto_inject(base_path: 'app.paths.base_path')

  # @!attribute environment
  #   @!visibility protected
  #   @return [Symbol]
  option(%w[-e --environment], 'ENVIRONMENT', 'Environment')

  # @!attribute server
  #   @!visibility protected
  #   @return [Symbol]
  option(%w[-s --server], 'SERVER', 'Server to run', default: :rhino)

  # @!attribute port
  #   @!visibility protected
  #   @return [Integer]
  option(%w[-p --port], 'PORT', 'Port to listen on', default: 8080) { |s| s ? Integer(s) : 8080 }

  def execute
    ENV['APP_ENV'] = options.fetch(:environment).to_s

    options.to_h.fetch(:server).to_sym.then do |server|
      ["Starting server #{server} ...", options].join("\n").each_line { |line| puts(line) }

      self.__send__(server == :rhino ? :rhino : :rackup, options)
    end
  end

  # @return [Symbol]
  def environment
    # noinspection RubyResolve
    (@environment || app_env).to_sym
  end

  # @return [Hash{Symbol => Object}]
  def options
    {
      port: port,
      environment: environment.to_s,
      server: server,
      config_file: base_path.join('config.ru').to_s,
    }
  end

  protected

  # Start a rhino server with given options.
  #
  # @param [Hash{Symbol => Object}] options
  def rhino(options)
    autoload(:Rhino, 'rhino')
    [
      '--port', options.fetch(:port),
      options.fetch(:config_file),
    ].then { |args| Rhino::CLI.new.parse(args.map(&:to_s)) }
  end

  # Start a rackup server with givem options.
  #
  # @param [Hash{Symbol => Object}] options
  #
  # @see Rack::server.default_options
  #
  # Rack server options:
  #
  # ```ruby
  # {:environment=>"development",
  #  :pid=>nil,
  #  :Port=>"8080",
  #  :Host=>"localhost",
  #  :AccessLog=>[],
  #  :config=>"config.ru",
  #  :server=>"thin"}
  # ```
  def rackup(options)
    autoload(:Rack, 'rack')
    {
      environment: options.fetch(:environment),
      Port: options.fetch(:port),
      config: options.fetch(:config_file),
      server: options.fetch(:server).to_s,
    }.then { |opts| Rack::Server.start(opts) }
  end
end
