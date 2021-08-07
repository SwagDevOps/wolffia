# frozen_string_literal: true

autoload(:FileUtils, 'fileutils')

results = {
  'BUNDLE_APP_CONFIG' => '.bundle',
  'BUNDLE_PATH' => 'bundle'
}.map { |k, v| [k.freeze, v.freeze] }.to_h.yield_self do |defaults|
  {
    empty: defaults,
    local: defaults.merge({ 'BUNDLE_FOO' => 'bar' }),
    ignored: defaults.merge({ 'BUNDLE_IGNORE_CONFIG' => true }),
    global: defaults.merge({ 'BUNDLE_FOO' => 'bar', 'BUNDLE_ANSWER' => 42 }),
  }
end.transform_values(&:freeze).freeze

lister = lambda do
  Dir.glob("#{SAMPLES_PATH}/configs/*/env.rb").map { |fp| Pathname.new(fp) }.keep_if(&:file?).map do |fp|
    [
      fp.dirname.basename.to_s.to_sym,
      {
        env: self.instance_eval(fp.read, fp.to_s, 0).to_h.sort.to_h,
        basedir: lambda do
          fp.dirname.join('basedir').tap { |dir| FileUtils.mkdir_p(dir) }
        end.call,
        result: results.fetch(fp.dirname.basename.to_s.to_sym, nil),
      }.yield_self { |h| Struct.new(*h.keys).new(*h.values) }
    ]
  end.to_h
end

{
  lister: lister,
}
