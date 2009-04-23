module Peegee
  module Clustering

    # Clusters this table. See http://www.postgresql.org/docs/8.3/interactive/sql-cluster.html
    # Optionally specify the index to cluster by (by name or Peegee::Index object).
    # The index to use would ideally be specified using the <tt>Peegee::Configuration</tt> 
    # instance. If the index is not specified, it will try to induce which index to 
    # use by looking at postgresql's internals. 
    # If a proper index can't be found, an exception will be raised.
    def cluster(cluster_index = nil)
      cluster_index = find_cluster_index(cluster_index)
      cache_dependencies
      ActiveRecord::Base.transaction do
        create_tmp_table
        move_data(cluster_index)
        dependent_foreign_keys.map { |dfk| dfk.drop }
        drop_original_and_rename_tmp_table
        indexes.map { |i| i.create }
        foreign_keys.map { |fk| fk.create }
        dependent_foreign_keys.map { |dfk| dfk.create }
        unique_constraints.map { |uc| uc.create }
      end
    end

    private

      # Retrieves the <tt>Peegee::Index</tt> object that will be used
      # for clustering this table. The <tt>cluster_index</tt> parameter can
      # be either a string representing the index name, or a <tt>Peegee::Index</tt> object.
      # Raises an exception if either a proper index was not found
      # or more than one index was found given a <tt>cluster_index</tt> name.
      def find_cluster_index(cluster_index)
        cluster_index = Peegee::Configuration.instance.cluster_indexes[self.table_name.to_sym].to_s if cluster_index.nil?
        return cluster_index if cluster_index.kind_of?(Peegee::Index)
        the_index = nil
        if cluster_index #cluster_index is specified
          the_index = indexes.select { |i| i.index_name == cluster_index}
        else #find cluster index from postgresql's information schema
          the_index = indexes.select { |i| i.is_clustered? }
        end
        raise "Ambiguous cluster_index definition. #{the_index.inspect}" if the_index.size != 1
        the_index[0] #this is surely an array of size one.
      end

      # Creates the tmp table to be used to temporarily hold
      # the data of the table being clustered. Additionally,
      # it assigns the sequence of the table to the tmp table.
      def create_tmp_table
        ActiveRecord::Base.connection.execute(tmp_ddl)
        reasign_sequence_to_tmp_table
      end

      # Moves the data contained in this table
      # to a tmp table in the order specified by
      # its cluster_index.
      def move_data(cluster_index)
        ActiveRecord::Base.connection.execute("insert into #{@table_name}_tmp select * from #{@table_name} order by #{cluster_index.order}")
      end


      # Returns the DDL for the tmp table where data is moved
      # to temporarily during clustering.
      def tmp_ddl
        ddl.gsub(/\b#{@table_name}\b/, "#{@table_name}_tmp")
      end

      # Alters the sequence of the table being clustered,
      # by assigning it to its temp table. This is necessary in order to
      # drop the table being clustered (to clean out the dependency on
      # the sequence).
      # This method is called after having created the tmp table, otherwise it will fail.
      #--
      # The method for finding a table's sequence is hackish. 
      # TODO: Find a better method for finding a table's sequence.
      def reasign_sequence_to_tmp_table
        sql = 'SELECT a.attname, ' +
            'pg_catalog.format_type(a.atttypid, a.atttypmod), ' +
            '(SELECT substring(pg_catalog.pg_get_expr(d.adbin, d.adrelid) for 128) ' +
            ' FROM pg_catalog.pg_attrdef d ' +
            ' WHERE d.adrelid = a.attrelid AND d.adnum = a.attnum AND a.atthasdef), ' +
            'a.attnotnull, a.attnum ' +
          'FROM pg_catalog.pg_attribute a ' +
          "WHERE a.attrelid = '#{@table_name}'::regclass AND a.attnum > 0 AND NOT a.attisdropped " +
          " and " +
            '(SELECT substring(pg_catalog.pg_get_expr(d.adbin, d.adrelid) for 128) ' +
            ' FROM pg_catalog.pg_attrdef d ' +
            " WHERE d.adrelid = a.attrelid AND d.adnum = a.attnum AND a.atthasdef) like '%nextval%' " +
          'ORDER BY a.attnum ' 
        seq = ActiveRecord::Base.connection.execute(sql).entries.flatten
        if !seq[0].nil? and !seq[2].empty?
          seq[2].match /nextval\('[\"']{0,2}(\w*)[\"']{0,2}.*'::regclass\)/
          sequence_name = $1 #the match above...
          ActiveRecord::Base.connection.execute("ALTER SEQUENCE \"#{sequence_name}\" OWNED BY #{@table_name}_tmp.#{seq[0]}")
        end
      end


      # Drops the table being clustered,
      # and renames the tmp table to its original name.
      def drop_original_and_rename_tmp_table
        sql = []
        sql << "drop table #{@table_name};"
        sql << "alter table #{@table_name}_tmp rename to #{@table_name};"
        sql.each do |s|
          ActiveRecord::Base.connection.execute(s + ';')
        end
      end

      def cache_dependencies
        dependent_foreign_keys
        foreign_keys
        indexes
        unique_constraints
      end

  end
end
