require 'active_record'
module SqlHelpers
  def connection
    @connection ||= begin
                    ActiveRecord::Base.establish_connection(
                      :adapter  => 'postgresql',
                      :encoding => 'unicode',
                      :database => 'peegee_development'
                    )
                    ActiveRecord::Base.connection
                  end
  end

  def select_all(sql)
    connection.select_all sql
  end

  def oid(table_name)
    select_all(<<-SQL).first['oid']
      SELECT c.oid
      FROM pg_catalog.pg_class c
        LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
      WHERE c.relname = '#{table_name}'
        AND pg_catalog.pg_table_is_visible(c.oid);
    SQL
  end

  def disconnect_test_db
    @connection.try(:disconnect!)
    @connection = nil
  end

end

World(SqlHelpers)
