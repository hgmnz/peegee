require File.dirname(__FILE__) + '/clustering'
module Peegee

  class Table
    include Peegee::Clustering
    
    def initialize(opts = {})
      @table_name = opts[:table_name]
    end

    def oid
      @oid ||= fetch_oid
    end

    def foreign_keys
      @foreign_keys ||= fetch_foreign_keys
    end

    def dependent_foreign_keys
      @dependent_foreign_keys ||= fetch_dependent_foreign_keys
    end

    def primary_keys
      @primary_keys ||= fetch_primary_keys
    end

    def unique_constraints
      @unique_constraints ||= fetch_unique_constraints
    end

    def indexes
      @indexes ||= fetch_indexes
    end

    # Returns the DDL for this table as a string.
    def ddl
      sql = 'SELECT a.attname, ' +
          'pg_catalog.format_type(a.atttypid, a.atttypmod), ' +
          '(SELECT substring(pg_catalog.pg_get_expr(d.adbin, d.adrelid) for 128) ' +
          ' FROM pg_catalog.pg_attrdef d ' +
          ' WHERE d.adrelid = a.attrelid AND d.adnum = a.attnum AND a.atthasdef), ' +
          'a.attnotnull, a.attnum ' +
        'FROM pg_catalog.pg_attribute a ' +
        "WHERE a.attrelid = '#{oid}' AND a.attnum > 0 AND NOT a.attisdropped " +
        'ORDER BY a.attnum ' 

      column_defs = ActiveRecord::Base.connection.execute(sql).entries

      ddl = "create table #{@table_name} ( "
      columns = []
      column_defs.each do |column_def|
        #name and type
        column = column_def[0] + ' ' + column_def[1] + ' '
        #not null?
        column += 'NOT NULL ' if column_def[3] == 't'
        #add modifiers:
        column += 'DEFAULT ' + column_def[2] unless (column_def[2].nil? || column_def[2].empty?)
        columns << column
      end

      ddl += columns.join(', ') + ' )'
      ddl.gsub('\\','')
    end


    private
      def fetch_oid
        sql = 'SELECT c.oid ' +
        ' FROM pg_catalog.pg_class c ' +
             ' LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace ' +
        " WHERE c.relname ~ '^(#{@table_name})$' " +
          ' AND pg_catalog.pg_table_is_visible(c.oid) '
        return ActiveRecord::Base.connection.execute(sql).entries[0]
      end



      def fetch_primary_keys
        sql = 'select  conname ' +
            ' , pg_get_constraintdef(pk.oid, true) as foreign_key ' +
            ' from pg_catalog.pg_constraint pk ' +
            ' inner join pg_class c ' +
            ' on c.oid = pk.conrelid ' +
            " where contype = 'p' " +
            " and c.oid = '#{@table_name}'::regclass "
        raw_pks = ActiveRecord::Base.connection.execute(sql).entries
        return raw_pks.collect do  |pk|
          Peegee::ForeignKey.new(#TODO: Consider passing table object (self)
                                 :table_name => @table_name,
                                 :constraint_name => pk[0],
                                 :constraint_def => pk[1])
        end
      end


      def fetch_unique_constraints
        sql = 'select  conname ' +
            ' , pg_get_constraintdef(uc.oid, true) as foreign_key ' +
            ' from pg_catalog.pg_constraint uc ' +
            ' inner join pg_class c ' +
            ' on c.oid = uc.conrelid ' +
            " where contype = 'u' " +
            " and c.oid = '#{@table_name}'::regclass "
        raw_ucs = ActiveRecord::Base.connection.execute(sql).entries
        return raw_ucs.collect do  |uc|
          Peegee::UniqueConstraint.new(#TODO: Consider passing table object (self)
                                 :table_name => @table_name,
                                 :constraint_name => uc[0],
                                 :constraint_def => uc[1])
        end
      end

      def fetch_foreign_keys
        sql = 'select  conname ' +
            ' , pg_get_constraintdef(fk.oid, true) as foreign_key ' +
            ' from pg_catalog.pg_constraint fk ' +
            ' inner join pg_class c ' +
            ' on c.oid = fk.conrelid ' +
            " where contype = 'f' " +
            " and c.oid = '#{@table_name}'::regclass "
        raw_fks = ActiveRecord::Base.connection.execute(sql).entries
        return raw_fks.collect do  |fk|
          Peegee::ForeignKey.new(#TODO: Consider passing table object (self)
                                 :table_name => @table_name,
                                 :constraint_name => fk[0],
                                 :constraint_def => fk[1])
        end

      end

      def fetch_dependent_foreign_keys
        sql = 'select pg_constraint.conname,' +
            'dep_table.relname, ' +
            'pg_get_constraintdef(pg_constraint.oid, true)  ' +
            'from pg_constraint  ' +
              'inner join pg_class dep_table on pg_constraint.conrelid = dep_table.oid ' +
              "where pg_constraint.confrelid = '#{@table_name}'::regclass; "
        raw_dpfks = ActiveRecord::Base.connection.execute(sql).entries
        return raw_dpfks.collect do |dpfk|
          Peegee::ForeignKey.new(#TODO: Consider passing table object (self)
                                 :table_name => dpfk[1],
                                 :constraint_name => dpfk[0],
                                 :constraint_def => dpfk[2])
        end
      end

      def fetch_indexes
        sql = "SELECT pg_get_indexdef(i.indexrelid, 0, true) as index_definition " +
            ", c2.relname as index_name " +
            ", i.indisclustered " +
            "FROM pg_catalog.pg_class c, pg_catalog.pg_class c2, pg_catalog.pg_index i " +
            "WHERE c.oid = '#{@table_name}'::regclass AND c.oid = i.indrelid AND i.indexrelid = c2.oid " #+
            #"AND i.indisprimary = false" #don't get primary key constraints...
        #indexes = ActiveRecord::Base.connection.execute(sql).entries.collect{ |i| i[0] + ';'}
        indexes = ActiveRecord::Base.connection.execute(sql).entries
        return indexes.collect do |i| 
          Peegee::Index.new(:table_name => @table_name,
                            :index_name => i[1],
                            :clustered => (i[2] == 't' ? true : false),
                            :def => i[0])
          end
      end



  end

end
