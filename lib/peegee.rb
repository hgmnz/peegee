require 'peegee/partial_index'

ActiveRecord::Migration.module_eval do
  extend Peegee::PartialIndex
end
