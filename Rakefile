require "bundler/setup"
require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'appraisal'

RSpec::Core::RakeTask.new(:spec)

task :default do
  exec('appraisal rspec')
end


