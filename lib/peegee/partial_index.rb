module Peegee
  module PartialIndex

    def add_index(table_name, column_name, options = {})
      super unless options[:where]

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

      quoted_column_names = quoted_columns_for_index(column_names, options).join(", ")

      execute "CREATE #{index_type} INDEX #{quote_column_name(index_name)} ON #{quote_table_name(table_name)} (#{quoted_column_names}) WHERE #{options[:where]}"
    end

  end
end
