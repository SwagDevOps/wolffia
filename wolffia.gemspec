# frozen_string_literal: true

# vim: ai ts=2 sts=2 et sw=2 ft=ruby
# rubocop:disable all

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
    "lib/wolffia/concurrent.rb",
    "lib/wolffia/container.rb",
    "lib/wolffia/container/injector.rb",
    "lib/wolffia/http.rb",
    "lib/wolffia/http/controller.rb",
    "lib/wolffia/http/response.rb",
    "lib/wolffia/http/router.rb",
    "lib/wolffia/mixins.rb",
    "lib/wolffia/mixins/injectable.rb",
    "lib/wolffia/version.rb",
    "lib/wolffia/version.yml",
  ]

  s.add_runtime_dependency("concurrent-ruby", ["~> 1.1.9"])
  s.add_runtime_dependency("dry-auto_inject", ["~> 0.8.0"])
  s.add_runtime_dependency("dry-container", ["~> 0.8.0"])
  s.add_runtime_dependency("hanami-router", ["~> 1.3.2"])
  s.add_runtime_dependency("kamaze-version", ["~> 1.0"])
  s.add_runtime_dependency("stibium-bundled", ["~> 0.0.1", ">= 0.0.4"])
  s.add_runtime_dependency("sys-proc", ["~> 1.1"])
end

# Local Variables:
# mode: ruby
# End:
