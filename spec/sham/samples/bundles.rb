# frozen_string_literal: true

results = {
  # results for the following methods:
  #
  # 0. Bundled.bundled?
  # 1. Bundled.bundled
  bundled: {
    empty: [FalseClass, NilClass],
    gemfile: [TrueClass, Stibium::Bundled::Bundle],
    gemfile_old: [TrueClass, Stibium::Bundled::Bundle],
    partial: [FalseClass, NilClass],
    partial_old: [FalseClass, NilClass],
    standalone: [TrueClass, Stibium::Bundled::Bundle]
  },
  # results for the following methods:
  #
  # 0. Bundled::Bundle.installed?
  'bundled/bundle': {
    empty: [FalseClass],
    gemfile: [FalseClass],
    gemfile_old: [FalseClass],
    partial: [FalseClass],
    partial_old: [FalseClass],
    standalone: [FalseClass]
  }
}

lister = lambda do
  Dir.glob("#{SAMPLES_PATH}/bundles/*").map { |fp| Pathname.new(fp) }.keep_if(&:directory?).map do |fp|
    [
      fp.basename.to_s.to_sym,
      {
        basedir: fp,
        env: {},
        ruby_config: {
          engine: 'ruby',
          version: '2.5.0',
        },
        results: results.transform_values { |v| v.fetch(fp.basename.to_s.to_sym) },
      }.tap do |h|
        h.merge!({
                   builder: lambda do |base: Class|
                     [[fp], { env: h.fetch(:env), ruby_config: h.fetch(:ruby_config) }].yield_self do |args|
                       base.new { (include Stibium::Bundled).bundled_from(*args.fetch(0), **args.fetch(1)) }
                     end
                   end,
                   outcome: ->(k, index) { h.fetch(:results).fetch(k).fetch(index) },
                 })
      end.yield_self { |h| Struct.new(*h.keys).new(*h.values) }
    ]
  end.sort.to_h
end

builder = lambda do |name, base: Class|
  lister.call.fetch(name.to_s.to_sym).builder.call(base: base)
end

{
  lister: lister,
  builder: builder,
}
