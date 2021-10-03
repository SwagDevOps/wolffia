# frozen_string_literal: true

autoload(:YAML, 'yaml')

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

apps_builder = lambda do |paths|
  paths.transform_values do |path|
    -> { Class.new(::Wolffia).call(path: path) }
  end
end

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
    valid_env_keys: paths.keys.keep_if { |v| v.to_s.match(/^valid_env_.+$/) }
  }
end
