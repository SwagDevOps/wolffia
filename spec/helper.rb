# frozen_string_literal: true

%w[../lib/wolffia wolffia].each do |req|
  __send__('.' == req[0] ? :require_relative : :require, req)
end

if Gem::Specification.find_all_by_name('sys-proc').any?
  require 'sys/proc'

  Sys::Proc.progname = 'rspec'
end

require_relative('helper/local').tap do
  self.singleton_class.instance_eval { include Local }
end

[
  :constants,
  :configure,
  :matchers,
].each do |req|
  require_relative '%<dir>s/%<req>s' % {
    dir: __FILE__.gsub(/\.rb$/, ''),
    req: req.to_s,
  }
end
