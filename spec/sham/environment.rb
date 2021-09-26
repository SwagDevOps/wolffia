# frozen_string_literal: true

autoload(:YAML, 'yaml')

environments_builder = lambda do
  SAMPLES_PATH.join('environment').glob('*.yml').map do |f|
    [
      f.basename('.*').to_s.to_sym,
      YAML.safe_load(f.read).to_h.transform_keys(&:to_sym).then do |parsed|
        ::Struct.new(*parsed.keys).new(*parsed.values)
      end
    ]
  end.to_h
end

{
  environments: environments_builder.call,
}
