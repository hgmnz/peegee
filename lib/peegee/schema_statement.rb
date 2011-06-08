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

      execute(index.create_sql)
    end
  end
end
