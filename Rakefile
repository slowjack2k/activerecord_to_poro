require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new

task :default => :spec
task :test => :spec

desc "Run RSpec with code coverage"
task :coverage do
  ENV['COVERAGE'] = "true"
  Rake::Task["spec"].execute
end
