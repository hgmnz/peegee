module Peegee
  module Index

    def add_index(table_name, column_name, options = {})
      column_names = Array.wrap(column_name)
      index_name   = index_name(table_name, :column => column_names)

      index_type = options[:unique] ? "UNIQUE" : ""
      index_name = options[:name].to_s if options.key?(:name)

      if index_name.length > index_name_length
        raise ArgumentError, "Index name '#{index_name}' on table '#{table_name}' is too long; the limit is #{index_name_length} characters"
      end
      if index_name_exists?(table_name, index_name, false)
        raise ArgumentError, "Index name '#{index_name}' on table '#{table_name}' already exists"
      end

      if column_name.kind_of?(Hash) && column_name.key?(:expression)
        quoted_column_names_or_expression = column_name[:expression]
      else
        quoted_column_names_or_expression = quoted_columns_for_index(column_names, options).join(", ")
      end

      sql = "CREATE #{index_type} INDEX #{quote_column_name(index_name)} ON #{quote_table_name(table_name)} (#{quoted_column_names_or_expression})"

      if options.key?(:where)
        sql += "WHERE #{options[:where]}"
      end
      execute sql
    end

  end
end
