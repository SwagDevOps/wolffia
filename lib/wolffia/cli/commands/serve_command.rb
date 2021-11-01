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
# @see https://github.com/alexch/rerun
#
# Sample of use:
#
# ```shell
# ruby www/app.rb serve
# ruby www/app.rb serve --server thin
# bundle exec rerun -b -- www/app.rb serve --server thin
# APP_ENV=staging ruby www/app.rb serve --server thin
# ```
class Wolffia::Cli::Commands::ServeCommand < ::Wolffia::Cli::Command
  self.description = 'Run a web server (based on rack)'

  # @api private
  FALLBACK_SERVER = :rackup

  class << self
    # @return [Symbol, nil]
    def default_server
      { rhino: :rhino, thin: :thin }
        .map { |gem_name, server| gem?(gem_name) ? server : nil }
        .compact.fetch(0)
    end

    protected

    # @param [String, Symbol] gem_name
    #
    # @return [Boolean]
    def gem?(gem_name)
      defined?(Gem) and Gem.loaded_specs.key?(gem_name.to_s)
    end
  end

  # @!attribute environment
  #   @!visibility protected
  #   @return [Wolffia::Environement]
  auto_inject(environment: 'app.env')

  # @!attribute base_path
  #   @!visibility protected
  #   @return [Pathname]
  auto_inject(base_path: 'app.paths.base_path')

  # @!attribute server
  #   @!visibility protected
  #   @return [Symbol]
  option(%w[-s --server], 'SERVER', 'Server to run', default: default_server.to_s) { |s| (s || default_server)&.to_sym }

  # @!attribute port
  #   @!visibility protected
  #   @return [Integer]
  option(%w[-p --port], 'PORT', 'Port to listen on', default: 8080) { |s| s ? Integer(s) : 8080 }

  def execute
    options.to_h.fetch(:server).then do |server|
      abort('Missing dependencies, install rhino and/or thin', status: 130) if server.nil?

      warn("Starting server #{server} (environment: #{environment})...")

      serve(server.to_sym)
    end
  end

  # @return [Hash{Symbol => Object}]
  def options
    {
      port: port,
      environment: environment.to_s,
      server: server,
      config_file: base_path.join('config.ru').realpath.to_s,
    }
  end

  # Get list of available servers (other than rackup servers)
  #
  # @return [Hash{Symbol => String}]
  def servers
    self.methods
        .keep_if { |v| v.to_s.match(/^serve_[a-z]+.*/) }
        .map { |v| [v.to_s.gsub(/^serve_/, '').to_sym, v.to_sym] }
        .keep_if { |v| v.fetch(0).to_sym != FALLBACK_SERVER.to_sym }
        .to_h
  end

  protected

  # @param [Symbol] server
  def serve(server)
    servers.fetch(server.to_sym, "serve_#{FALLBACK_SERVER}").then do |method|
      self.__send__(method, options)
    end
  end

  # Start a rhino server with given options.
  #
  # @param [Hash{Symbol => Object}] options
  def serve_rhino(options)
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
  def serve_rackup(options)
    autoload(:Rack, 'rack')

    {
      environment: ENV['RACK_ENV'] || options.fetch(:environment),
      Port: options.fetch(:port),
      config: options.fetch(:config_file),
      server: options.fetch(:server).to_s,
    }.then { |opts| Rack::Server.start(opts) }
  end
end
