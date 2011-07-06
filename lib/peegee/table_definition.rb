require 'active_record/connection_adapters/abstract/schema_definitions' ### TODO: railtie
require 'active_record/connection_adapters/abstract/schema_statements' ### TODO: railtie

ActiveRecord::ConnectionAdapters::TableDefinition.class_eval do
  def references(*args)
    options = args.extract_options!
    polymorphic = options.delete(:polymorphic)
    args.each do |col|
      column("#{col}_id", :integer, options.merge(:references => col)) # only change
      column("#{col}_type", :string, polymorphic.is_a?(Hash) ? polymorphic : options) unless polymorphic.nil?
    end
  end

  def column_with_references(name, type, options = {})
    column_definition = ActiveRecord::ConnectionAdapters::ColumnDefinition.new(@base, name, type)
    column_definition.options = options
    @columns << column_definition

    column_without_references(name, type, options)
  end
  alias_method_chain :column, :references
end

ActiveRecord::ConnectionAdapters::ColumnDefinition.class_eval do
  def options=(options)
    @options = options
  end

  def to_sql
    column_sql = "#{base.quote_column_name(name)} #{sql_type}"
    column_options = {}
    column_options[:null] = null unless null.nil?
    column_options[:default] = default unless default.nil?
    column_options[:references] = @options[:references] # only change
    add_column_options!(column_sql, column_options) unless type.to_sym == :primary_key
    column_sql
  end
end

ActiveRecord::ConnectionAdapters::SchemaStatements.module_eval do
  def add_column_options_with_references!(sql, options) #:nodoc:
    sql << " REFERENCES #{options[:references].to_s.pluralize} (id)" if options[:references]

    add_column_options_without_references!(sql, options)
  end
  alias_method_chain :add_column_options!, :references
end
