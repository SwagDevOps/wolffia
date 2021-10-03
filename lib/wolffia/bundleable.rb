# frozen_string_literal: true

# Copyright (C) 2017-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../wolffia' unless defined?(::Wolffia)

# @see https://github.com/SwagDevOps/stibium-bundled
module Wolffia::Bundleable
  autoload(:Pathname, 'pathname')
  autoload(:RbConfig, 'rbconfig')

  # Functor executed in a bundled environment.
  #
  # @type [Stibium::Bundled::Bundle] bundle
  BUNDLE_HANDLER = lambda do |bundle|
    with_bundle(bundle) do
      require 'kamaze/project/core_ext/pp' if gems_for(bundle)&.include?('kamaze-project')
    end
  end

  class << self
    private

    def included(othermod)
      # noinspection RubyNilAnalysis, RubyResolve
      Pathname.new(caller_locations.fetch(0).path).dirname.join('..').expand_path.freeze.yield_self do |basedir|
        loader.call(basedir)
      ensure
        othermod
          .__send__(:include, ::Stibium::Bundled)
          .__send__(:bundled_from, basedir, setup: true, &bundle_handler)
      end
    end

    # @api private
    #
    # @return [Proc]
    def bundle_handler
      BUNDLE_HANDLER
    end

    # @api private
    #
    # @return [Proc]
    def loader
      # @type [String, Pathname] basedir
      lambda do |basedir|
        [
          [RUBY_ENGINE, RbConfig::CONFIG.fetch('ruby_version'), 'bundler/gems/*/stibium-bundled.gemspec'],
          [RUBY_ENGINE, RbConfig::CONFIG.fetch('ruby_version'), 'gems/stibium-bundled-*/lib/'],
        ].map { |parts| Pathname.new(basedir).join(*['{**/,}bundle'].concat(parts)) }.yield_self do |patterns|
          # noinspection RubyResolve
          Pathname.glob(patterns).first&.dirname&.tap { |gem_dir| require gem_dir.join('lib/stibium/bundled') }
        end
      end
    end

    # @param [Stibium::Bundled::Bundle] bundle
    def with_bundle(bundle, &block)
      block.call(bundle) if bundled_with?(bundle)
    end

    # @param [Stibium::Bundled::Bundle] bundle
    #
    # @return [Boolean]
    def bundled_with?(bundle)
      bundle.locked? and bundle.installed?
    end

    # Get gems name from bundle specfication.
    #
    # @param [Stibium::Bundled::Bundle] bundle
    #
    # @return [Array<string>, nil]
    def gems_for(bundle)
      return nil unless Object.const_defined?(:Gem)

      bundle.specifications.map { |v| v.name.to_s }
    end
  end
end
