# frozen_string_literal: true

register(:json, memoize: true) do
  (require 'json').yield_self { JSON }
end

register(:logger, memoize: true) { ::Wolffia::Logger.new }

volatile_get(:environment).tap do |environment|
  register('app.env', memoize: true) { environment }
end

volatile_get(:paths).tap do |paths|
  register('app.paths', memoize: true) { paths }
  paths.each { |name, path| self["app.paths.#{name}_path"] = path }
end

volatile_get(:settings_params).tap do |params|
  register('app.settings', memoize: true) { ::Wolffia::Config.new(*params).settings }
end

volatile_get(:router_options).tap do |options|
  register(:'http.router', memoize: true) do
    ::Wolffia::HTTP::Router.new(**options).register(container: self)
  end
end

volatile_get(:commands).tap do |commands|
  register(:cli, memoize: true) { ::Wolffia::Cli.build(commands) }
end
