# frozen_string_literal: true

autoload(:YAML, 'yaml')

builder = lambda do
  SAMPLES_PATH.join('version', 'version.yml').then do |path|
    YAML.safe_load(path.read).to_h.transform_keys(&:to_sym).then do |parsed|
      ::Struct.new(*parsed.keys).new(*parsed.values)
    end
  end
end

# result --------------------------------------------------------------

{
  to_h: builder.call.to_h,
}
