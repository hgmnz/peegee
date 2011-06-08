module Peegee
  module SchemaStatement
    def add_index(table_name, *args)
      options              = {}
      options              = args.pop if args.last.respond_to?(:key?)
      column_or_expression = args.first
      index = Peegee::Index.new(:table_name => table_name,
                                :options    => options)
      if block_given?
        yield index
      else
        index.column_or_expression = column_or_expression
      end

      execute(index.create_sql)
    end
  end
end
