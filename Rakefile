require 'bundler'
Bundler::GemHelper.install_tasks

require 'cucumber/rake/task'
require 'rspec/core/rake_task'
require 'herodotus/tasks'

Herodotus::Configuration.run do |config|
  config.base_path          = File.dirname __FILE__
  config.changelog_filename = 'CHANGES'
end

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format progress"
end

RSpec::Core::RakeTask.new(:spec)

task :default => [:spec,:features]
