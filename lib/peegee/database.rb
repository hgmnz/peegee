module Peegee
  class Database

    protected 
      def self.register_table(table)
        if (@tables ||= {}).has_key?(table.table_name.to_sym)
          return @tables[table.table_name.to_sym]
        else
          @tables[table.table_name.to_sym] = table
          return table
        end
      end

  end
end
