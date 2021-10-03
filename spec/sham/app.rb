# frozen_string_literal: true

autoload(:YAML, 'yaml')

# List paths --------------------------------------------------------
paths_builder = lambda do
  SAMPLES_PATH.join('app').then do |path|
    path.entries
        .sort
        .reject { |v| %w[. ..].include?(v.to_path) }
        .map { |fp| path.join(fp).realpath }
        .keep_if(&:directory?)
        .map { |dirpath| [dirpath.basename.to_s.to_sym, dirpath] }
        .to_h
  end
end

# Build an app form a path, with an empty env -----------------------
apps_builder = lambda do |paths|
  paths.transform_values do |path|
    lambda do |env: {}|
      Class.new(::Wolffia).then do |klass|
        with_env(env) { klass.call(path: path) }
      end
    end
  end
end

# Retrieve exepectations --------------------------------------------
expectations_builder = lambda do |paths|
  paths.transform_values do |dir|
    YAML.safe_load(dir.join('expectations.yml').read).to_h.transform_keys(&:to_sym).then do |parsed|
      ::Struct.new(*parsed.keys).new(*parsed.values)
    end
  end
end

# result --------------------------------------------------------------

paths_builder.call.then do |paths|
  {
    paths: paths,
    builders: apps_builder.call(paths),
    expectations: expectations_builder.call(paths),
    valid_env_keys: paths.keys.keep_if { |v| v.to_s.match(/^valid_env_.+$/) },
    invalid_env_keys: paths.keys.keep_if { |v| v.to_s.match(/^invalid_env_.+$/) },
  }
end
