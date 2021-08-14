# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../mixins'

# Provide env method.
module Wolffia::Mixins::Env
  autoload(:YAML, 'yaml')

  protected

  def env(key, default = nil)
    ENV.key?(key) ? YAML.safe_load(ENV.fetch(key)) : default
  end
end
