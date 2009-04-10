module Peegee
  class ForeignKey < Peegee::Constraint

    def initialize(opts)
      super(opts)
    end

    # Returns the name of this foreign key.
    def foreign_key_name
      @constraint_name
    end

    # Returns human readable foreign key definition
    def to_s
      "Foreign Key: #{foreign_key_name} on #{table_name}"
    end

  end
end
