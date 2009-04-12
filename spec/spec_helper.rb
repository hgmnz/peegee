require 'spec'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'peegee'

require 'spec/peegee_helper'
#ActiveRecord::Base.logger = Logger.new(StringIO.new)
#
require 'factory_girl'

Spec::Runner.configure do |config|
  Kernel.const_set :RAILS_ROOT, "#{Dir.pwd}/tmp" unless defined?(RAILS_ROOT)
  #PeegeeHelper.new
  require 'spec/fixtures/activerecord_models'
end
