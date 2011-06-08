module Peegee
  module Quoting
    extend self

    def quoted_columns_for_index(column_name)
      PGconn.quote_ident(column_name.to_s)
    end
  end
end
