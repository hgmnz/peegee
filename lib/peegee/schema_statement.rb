module Peegee
  module SchemaStatement
    def add_index(table_name, column_or_expression, options = {})
      index = Peegee::Index.new(:table_name           => table_name,
                                :column_or_expression => column_or_expression,
                                :options              => options)
      execute(index.create_sql)
    end
  end
end
