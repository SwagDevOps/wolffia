# frozen_string_literal: true

require 'sys/proc'
Sys::Proc.progname = nil

# coverage ------------------------------------------------------------
if Gem::Specification.find_all_by_name('simplecov').any?
  autoload(:YAML, 'yaml')
  autoload(:SimpleCov, 'simplecov')

  if YAML.safe_load(ENV['coverage'].to_s) == true
    SimpleCov.start do
      add_filter 'rake/'
      add_filter 'spec/'
    end
  end
end

# main ----------------------------------------------------------------
require_relative './rake/rake'
