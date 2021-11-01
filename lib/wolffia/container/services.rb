# frozen_string_literal: true

register(:json, memoize: true) do
  (require 'json').yield_self { JSON }
end

# logger ----------------------------------------------------------------------
register(:logger, memoize: true) do
  ::Wolffia::Logger.new do |config|
    config.name = :web
  end
end

# paths -----------------------------------------------------------------------
volatile_get(:paths).tap do |paths|
  register('app.paths', memoize: true) { paths }
  paths.each { |name, path| self["app.paths.#{name}_path"] = path }
end

# app -------------------------------------------------------------------------
volatile_get(:environment).tap do |environment|
  register('app.env', memoize: true) { environment }
end

volatile_get(:'app.instance').tap do |app|
  register('app.instance', memoize: true) { app }
end

volatile_get(:settings_params).tap do |params|
  register('app.settings', memoize: true) { ::Wolffia::Config.new(*params).settings }
end

# router ----------------------------------------------------------------------
volatile_get(:router_options).tap do |options|
  register(:'http.router', memoize: true) do
    ::Wolffia::HTTP::Router.new(**options).register(container: self)
  end
end

# cli -------------------------------------------------------------------------
volatile_get(:commands).tap do |commands|
  register(:cli, memoize: true) { ::Wolffia::Cli.build(commands) }
end

# rubygems --------------------------------------------------------------------
if defined?(:Gem)
  if Gem.loaded_specs.is_a?(::Hash) # rubocop:disable Style/SoleNestedConditional
    register(:'gem.loaded_specs', memoize: true) do
      Gem.loaded_specs.transform_keys { |key| key.to_s.freeze }
    end
  end
end
