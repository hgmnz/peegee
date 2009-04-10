module Peegee
  class UniqueConstraint

    def initialize(opts)
      super(opts)
    end

    # Returns the name of this unique constraint
    def unique_constraint_name
      @constraint_name
    end

    #returns human readable unique constraint definition
    def to_s
      "Unique Constraint: #{unique_constraint_name} on #{table_name}"
    end

  end
end
