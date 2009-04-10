module Peegee
  class PrimaryKey < Peegee::Constraint

    def initialize(opts)
      super(opts)
    end

    # Returns the name of this primary key.
    def primary_key_name
      @constraint_name
    end

    # Returns human readable primary key definition
    def to_s
      "Primary Key: #{primary_key_name} on #{@table_name}"
    end

  end
end
