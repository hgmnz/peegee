module Peegee
  class Constraint

    def initialize(opts = {})
      @table_name = opts[:table_name]
      @constraint_name = opts[:constraint_name]
      @constraint_def = opts[:constraint_def]
    end

    # Returns human readable constraint.
    def to_s
      "Constraint: #{@constraint_name} on #{table_name}"
    end

    # Creates this constraint definition.
    def create
      sql = "alter table #{@table_name} add constraint #{@constraint_name} #{@constraint_def}"
      ActiveRecord::Base.connection.execute(sql)
    end

    # Drops this constraint.
    def drop
      sql = "alter table #{@table_name} drop constraint #{@constraint_name}"
      ActiveRecord::Base.connection.execute(sql)
    end

  end
end
