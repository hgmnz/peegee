module Peegee
  module Quoting
    extend self
    def quoted_columns_for_index(column_names)
      column_names.map {|name| quote_column_name(name) }
    end

    def quote_column_name(name)
      PGconn.quote_ident(name.to_s)
    end
  end
end
