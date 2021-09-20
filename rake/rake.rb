# frozen_string_literal: true

require_relative '../lib/wolffia'
require 'wolffia'
require 'kamaze/project'

# noinspection RubyLiteralArrayInspection
[
  'cs:correct', 'cs:control',
  'cs:pre-commit',
  'doc', 'doc:watch',
  'gem', 'gem:compile',
  'misc:gitignore',
  'shell', 'sources:license',
  'test',
].then do |tasks|
  Kamaze.project do |project|
    project.subject = Wolffia
    project.name = 'wolffia'
    project.tasks = tasks
  end.load!
end

# default task --------------------------------------------------------
task default: [:gem]

# tasks ---------------------------------------------------------------
Dir.glob("#{__dir__}/tasks/**/*.rb").sort.each { |fp| require(fp) }
