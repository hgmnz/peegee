module Peegee
  class Index

    attr_accessor :index_name, :table_name, :clustered, :def

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
    #--
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
    #
    # The <tt>cascade</tt> can be set to true to drop any 
    # dependencies of the index. The default is +false+.
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

    #def clustered=(clustered)
      #@clustered = clustered
      #sql_value = clustered ? "\"t\"" : "\"f\""
      #sql = "update pg_index set indisclustered = #{sql_value} where "
    #end

    # Finds and returns Index object, given the index name.
    # The optional table_name is required when 
    # the index_name is not unique, ie: More than one
    # index with that name was found on PostgreSQL's 
    # information catalog.
    def self.find(index_name)
        raw_index = fetch_raw_index(index_name)
        return nil if raw_index.nil?
        Peegee::Index.new(:table_name => raw_index[3],
                          :index_name => raw_index[1],
                          :clustered => (raw_index[2] == 't' ? true : false),
                          :def => raw_index[0])
    end

    # Similar to find, but raises an IndexNotFoundException if
    # an index by the provided <tt>index_name</tt> was not found.
    def self.find!(index_name)
        raw_index = fetch_raw_index(index_name)
        raise IndexNotFoundError if raw_index.nil?
        Peegee::Index.new(:table_name => raw_index[3],
                          :index_name => raw_index[1],
                          :clustered => (raw_index[2] == 't' ? true : false),
                          :def => raw_index[0])
    end

    # <tt>true</tt> if an index called <tt>index_name</tt> exists. False otherwise.
    def self.exists?(index_name)
      sql = "select * from pg_class where relname = '#{index_name}' and relkind = 'i';"
      return ActiveRecord::Base.connection.execute(sql).entries.size > 0
    end

    private
      # Never call this directly. Use find or find! instead.
      def self.fetch_raw_index(index_name)
        return nil unless self.exists?(index_name)
        sql = <<-END_SQL
        SELECT pg_get_indexdef(i.indexrelid, 0, true) as index_definition 
        , c2.relname as index_name 
        , i.indisclustered 
        , c.relname
        FROM pg_catalog.pg_class c
          inner join pg_catalog.pg_index i
            on c.oid = i.indrelid
          inner join pg_catalog.pg_class c2
            on i.indexrelid = c2.oid
        WHERE c2.oid = '#{index_name}'::regclass 
        END_SQL
        raw_index = ActiveRecord::Base.connection.execute(sql).entries
        raw_index[0]
      end

  end
end
