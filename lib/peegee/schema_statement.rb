module Peegee
  module SchemaStatement
    def add_index(table_name, *args)
      options = args.last.respond_to?(:key?) ? args.pop : {}
      column  = args.first

      index = Peegee::Index.new(:table_name => table_name,
                                :options    => options)
      if block_given?
        yield index
      else
        index.column = column
      end

      if index.run_outside_transaction?
        commit_db_transaction
        execute(index.create_sql)
        begin_db_transaction
      else
        execute(index.create_sql)
      end
    end
  end
end
