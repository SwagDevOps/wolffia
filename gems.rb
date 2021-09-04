# frozen_string_literal: true

# ```sh
# bundle config set --local clean 'true'
# bundle config set --local path 'vendor/bundle'
# bundle install --standalone
# ```
source 'https://rubygems.org'

def github(repo, options = {}, &block)
  block ||= -> { gem(*[File.basename(repo)].concat([{ github: repo }.merge(options)])) }

  # noinspection RubySuperCallWithoutSuperclassInspection
  super(repo, options, &block)
end

group :default do
  gem 'autoloaded', '~> 2.3'
  gem 'concurrent-ruby', '~> 1.1'
  gem 'config', '~> 3.1'
  gem 'dotenv', '~> 2.7'
  gem 'dry-auto_inject', '~> 0.8'
  gem 'dry-container', '~> 0.8'
  gem 'hanami-router', '~> 1.3'
  gem 'kamaze-version', '~> 1.0'
  gem 'stibium-bundled', '~> 0.0', '>= 0.0.4'
  gem 'sys-proc', '~> 1.1'
end

group :development do
  github 'SwagDevOps/kamaze-project', { branch: 'develop' }
  gem 'listen', '~> 3.1'
  gem 'rake', '~> 13.0'
  gem 'rubocop', '~> 1.3'
  gem 'rugged', '~> 1.0'
  # repl ---------------------------------
  gem 'interesting_methods', '~> 0.1'
  gem 'pry', '~> 0.12'
  # web ----------------------------------
  gem 'better_errors', '~> 2.9'
  gem 'binding_of_caller', '~> 1.0'
  gem 'thin', '~> 1.8'
  gem 'webrick', '~> 1.6'
  github 'ksylvest/rhino', { branch: 'master' }
  github 'alexch/rerun', { branch: 'master' }
  github 'sqm/http_router', { branch: 'master' }
end

group :doc do
  gem 'github-markup', '~> 3.0'
  gem 'redcarpet', '~> 3.5'
  gem 'yard', '~> 0.9'
  gem 'yard-coderay', '~> 0.1'
end

group :test do
  gem 'rspec', '~> 3.8'
end
