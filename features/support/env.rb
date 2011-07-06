require 'aruba/cucumber'
require 'ruby-debug'
require 'active_support/inflector'

PROJECT_ROOT = File.expand_path('../..', File.dirname(__FILE__))

Before do
  @aruba_timeout_seconds = 10
end

After do
  FileUtils.rm_rf(File.join(PROJECT_ROOT, 'tmp', 'aruba', 'peegee_test'))
  disconnect_test_db
end
