module Peegee
  class Index

    attr_accessor :index_name

    def initialize(opts = {})
      @table_name = opts[:table_name]
      @index_name = opts[:index_name]
      @clustered = opts[:clustered]
      @def = opts[:def]
    end

    # prints human readable index definition
    def to_s
      "Index: #{@index_name} on #{@table_name} => (#{columns})"
    end

    # Returns the columns affected by this index
    # TODO: Find out if there's a better way to 
    # retreive the column list, via postgres internals.
    #
    # TODO: Find out if this is the cleanest way to get 
    # the match of the regex
    def columns
      raise "Can't find index order for #{@index_name}" unless @def.match /\((.*)\)/
      $1 #return the regex match (column list)
    end

    alias_method :order, :columns

    # Drops this index
    def drop
      ActiveRecord::Base.connection.execute(drop_statement)
    end

    # Constructs the SQL statement to drop this index
    # Optionally, pass in the boolean cascade value to
    # also drop any dependent DB objects.
    #
    # PostgreSQL will error out if the index does not exists
    # We purposely do not work around that.
    def drop_statement(cascade = false)
      drop_statement = "DROP INDEX \"#{@index_name}\""
      drop_statement += " CASCADE" if cascade
      drop_statement
    end

    # Creates this index
    def create
      ActiveRecord::Base.connection.execute(@def)
    end

    # returns true if this was the last clustered index
    # on the associated table
    def is_clustered?
      @clustered
    end

    # Builds and returns Index object, given the index name
    # The optional table_name is required when 
    # the index_name is not unique, ie: More than one
    # index with that name was found on PostgreSQL's 
    # information catalog.
    # If more than one index by that name is found, 
    # and table_name is not specified, an exception is raised.
    # TODO: write implementation of this method...
    def self.build(index_name, table_name = nil)

    end

  end
end
