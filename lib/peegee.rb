require 'peegee/index'

ActiveRecord::Migration.module_eval do
  extend Peegee::Index
end
