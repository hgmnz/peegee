module Peegee
  class Database

    #def self.object_exists?(object_name)
      #sql = <<-END_SQL
        #select * from pg_class where relname = '#{object_name}' limit 1
      #END_SQL
      #ActiveRecord::Base.connection.execute(sql).entries.size > 0
    #end

    def self.register_table(table)
      if (@tables ||= {}).has_key?(table.table_name.to_sym)
        return @tables[table.table_name.to_sym]
      else
        @tables[table.table_name.to_sym] = table
        return table
      end
    end

    def self.forget_table_register!
      @tables = {}
    end

  end
end
