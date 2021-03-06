module Peegee
  class Index

    attr_accessor :index_name, :table_name, :options, :uniqueness
    attr_accessor :columns_or_expressions

    def initialize(options = {})
      self.table_name             = options[:table_name]
      self.columns_or_expressions = options.key?(:column) ? [[:column, options[:column], []]] : []
      self.options                = options[:options]
    end

    def create_sql
      check_index_name_length

      sql = "CREATE #{uniqueness} INDEX #{concurrentliness} #{adapter.quote_column_name(index_name)} ON #{adapter.quote_table_name(table_name)} (#{columns_or_expressions_sql}) #{tablespace_sql}"
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

    def run_outside_transaction?
      options[:concurrently]
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
      hash_options = options.last.respond_to?(:key?) ? options.pop : {}

      "#{column_single_options_sql(options)} #{column_hash_options_sql(hash_options)}"
    end

    def column_single_options_sql(options)
      options.first.try(:to_s).try(:upcase) || ""
    end

    def column_hash_options_sql(options)
      options.inject("") do |acc, (k,v)|
        "#{k.to_s.upcase} #{v.to_s.upcase} #{acc}"
      end
    end

    def tablespace_sql
      self.options[:tablespace] ? "TABLESPACE #{self.options[:tablespace]}" : ""
    end

    def uniqueness
      self.options[:unique] ? "UNIQUE" : ""
    end

    def concurrentliness
      self.options[:concurrently] ? "CONCURRENTLY" : ""
    end

    def index_name
      options[:name] || default_index_name
    end

    def default_index_name
      column_name = columns_or_expressions.select {|type, _, _| type == :column}.inject("") do |acc,(_,name,_)|
        "#{acc}_#{name}"
      end
      adapter.index_name(table_name, :column => "#{column_name}_auto")
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
