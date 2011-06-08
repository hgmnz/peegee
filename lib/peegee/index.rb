module Peegee
  class Index

    attr_accessor :index_name, :table_name, :options, :uniqueness
    attr_accessor :columns_or_expressions

    def initialize(options = {})
      self.table_name             = options[:table_name]
      self.columns_or_expressions = options.key?(:column) ? [:column, [options[:column], []]] : []
      self.options                = options[:options]
    end

    def create_sql
      check_index_name_length

      sql = "CREATE #{uniqueness} INDEX #{adapter.quote_column_name(index_name)} ON #{adapter.quote_table_name(table_name)} (#{columns_or_expressions_sql})"
      if @options.key?(:where)
        sql += " WHERE #{options[:where]}"
      end

      sql
    end

    def column(name, *args)
      columns_or_expressions << [:column, name, args]
    end

    def expression(expr, *args)
      columns_or_expressions << [:expression, expr, args]
    end

    def column=(column)
      columns_or_expressions << [:column, column, []]
    end

    private

    def columns_or_expressions_sql
      self.columns_or_expressions.map do |tag,column_or_expression,args|
        column_or_expression_sql(tag, column_or_expression, args)
      end.join(', ')
    end

    def column_or_expression_sql(tag, column_or_expression, args)
      case tag
      when :column
        "#{Peegee::Quoting.quoted_columns_for_index(column_or_expression)} #{column_options_sql(args)}"
      when :expression
        column_or_expression
      else
        raise RuntimeError
      end
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
