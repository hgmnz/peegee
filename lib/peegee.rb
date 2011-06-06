require 'peegee/index'
require 'peegee/schema_statement'
require 'peegee/quoting'

ActiveRecord::Migration.module_eval do
  extend Peegee::SchemaStatement
end
