# frozen_string_literal: true

# vim: ai ts=2 sts=2 et sw=2 ft=ruby
# rubocop:disable all

# noinspection RubyLiteralArrayInspection
Gem::Specification.new do |s|
  s.name        = "wolffia"
  s.version     = "0.0.1"
  s.date        = "2020-08-06"
  s.summary     = "lightweight web framework"
  s.description = "A simple lightweight web framework"

  s.licenses    = ["GPL-3.0"]
  s.authors     = ["Dimitri Arrigoni"]
  s.email       = "dimitri@arrigoni.me"
  s.homepage    = "https://github.com/SwagDevOps/wolffia"

  s.required_ruby_version = ">= 2.7.0"
  s.require_paths = ["lib"]
  s.bindir        = "bin"
  s.executables   = [
  ]
  s.files         = [
    ".yardopts",
    "README.md",
    "lib/wolffia.rb",
    "lib/wolffia/bundleable.rb",
    "lib/wolffia/cli.rb",
    "lib/wolffia/cli/app.rb",
    "lib/wolffia/cli/builder.rb",
    "lib/wolffia/cli/commands.rb",
    "lib/wolffia/cli/commands/serve_command.rb",
    "lib/wolffia/concurrent.rb",
    "lib/wolffia/config.rb",
    "lib/wolffia/container.rb",
    "lib/wolffia/container/builder.rb",
    "lib/wolffia/container/services.rb",
    "lib/wolffia/container/volatile.rb",
    "lib/wolffia/dotenv.rb",
    "lib/wolffia/environment.rb",
    "lib/wolffia/errors.rb",
    "lib/wolffia/errors/core.rb",
    "lib/wolffia/errors/core/missing_injector_error.rb",
    "lib/wolffia/has_paths.rb",
    "lib/wolffia/http.rb",
    "lib/wolffia/http/controller.rb",
    "lib/wolffia/http/middleware.rb",
    "lib/wolffia/http/middleware/loader.rb",
    "lib/wolffia/http/middleware/parser.rb",
    "lib/wolffia/http/request.rb",
    "lib/wolffia/http/response.rb",
    "lib/wolffia/http/router.rb",
    "lib/wolffia/http/router/handler_builder.rb",
    "lib/wolffia/inheritance.rb",
    "lib/wolffia/logger.rb",
    "lib/wolffia/logger/loggable.rb",
    "lib/wolffia/mixins.rb",
    "lib/wolffia/mixins/env.rb",
    "lib/wolffia/mixins/injectable.rb",
    "lib/wolffia/mixins/injectable/handler.rb",
    "lib/wolffia/mixins/injectable/visitor.rb",
    "lib/wolffia/version.rb",
    "lib/wolffia/version.yml",
  ]

  s.add_runtime_dependency("autoloaded", ["~> 2.3"])
  s.add_runtime_dependency("clamp", ["~> 1.3"])
  s.add_runtime_dependency("concurrent-ruby", ["~> 1.1"])
  s.add_runtime_dependency("config", ["~> 3.1"])
  s.add_runtime_dependency("dotenv", ["~> 2.7"])
  s.add_runtime_dependency("dotenv_validator", ["~> 1.1"])
  s.add_runtime_dependency("dry-container", ["~> 0.8"])
  s.add_runtime_dependency("hanami-router", ["~> 1.3"])
  s.add_runtime_dependency("kamaze-version", ["~> 1.0"])
  s.add_runtime_dependency("rbminivents", ["~> 0.2"])
  s.add_runtime_dependency("ruby_parser", ["~> 3.17"])
  s.add_runtime_dependency("stibium-bundled", ["~> 0.0", ">= 0.0.4"])
  s.add_runtime_dependency("sys-proc", ["~> 1.1"])
end

# Local Variables:
# mode: ruby
# End:
