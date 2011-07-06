require 'peegee/index'
require 'peegee/schema_statement'
require 'peegee/quoting'
require 'peegee/table_definition'

ActiveRecord::Migration.module_eval do
  extend Peegee::SchemaStatement
end
