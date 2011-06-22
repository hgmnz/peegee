require 'active_support/core_ext'
require 'support/sql_helpers'
require 'peegee'

RSpec.configure do |c|
  c.include SqlHelpers
  c.before(:all) { connection }
  c.after(:all) { disconnect_test_db }
end
