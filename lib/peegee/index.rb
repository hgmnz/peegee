module Peegee
  class Index

    attr_accessor :index_name, :table_name, :options, :uniqueness
    attr_accessor :columns_or_expressions

    def initialize(options = {})
      self.table_name             = options[:table_name]
      self.columns_or_expressions = options.key?(:column_or_expression) ? [[options[:column_or_expression].to_s, []]] : []
      self.options                = options[:options]
    end

    def create_sql
      check_index_name_length

      sql = "CREATE #{uniqueness} INDEX #{adapter.quote_column_name(index_name)} ON #{adapter.quote_table_name(table_name)} (#{column_or_expression_sql})"
      if @options.key?(:where)
        sql += " WHERE #{options[:where]}"
      end

      sql
    end

    def column(name, *args)
      columns_or_expressions << [name.to_s, args]
    end

    private

    def column_or_expression_sql
      self.columns_or_expressions.map do |column_or_expression|
        "#{Peegee::Quoting.quoted_columns_for_index(column_or_expression.first)} #{column_options_sql(column_or_expression.last)}"
      end.join(', ')
    end

    def column_options_sql(options)
      options.first.to_s.upcase
    end

    def uniqueness
      self.options[:unique] ? "UNIQUE" : ""
    end

    def index_name
      options[:name] || adapter.index_name(table_name, :column => column_or_expression)
    end

    def check_index_name_length
      if index_name.length > index_name_length
        raise ArgumentError, "Index name '#{index_name}' on table '#{table_name}' is too long; the limit is #{index_name_length} characters"
      end
      if adapter.index_name_exists?(table_name, index_name, false)
        raise ArgumentError, "Index name '#{index_name}' on table '#{table_name}' already exists"
      end
    end

    def index_name_length
      adapter.index_name_length
    end

    def adapter
      ActiveRecord::Base.connection
    end
  end
end
