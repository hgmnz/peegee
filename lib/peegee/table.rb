require File.dirname(__FILE__) + '/clustering'
module Peegee

  class Table
    include Peegee::Clustering

    attr_accessor :table_name
    
    private_class_method :new
    # new can't be called on this class.
    # Use find instead. Using find will 
    # register the Table instance
    def initialize(table_name)
      @table_name = table_name
    end

    # Finds the table given by +table_name+ and
    # returns an instance of Peegee::Table.
    # A TableNotFoundError is thrown if the table
    # with the supplied +table_name+ is not found in the database.
    def self.find(opts)
      table_name = opts[:table_name] || opts
      if Peegee::Table.exists?(table_name)
        t = new(table_name)
        return Peegee::Database.register_table(t)
      else
        raise TableNotFoundError, "Table #{table_name} does not exist", caller
      end
    end

    # Class method that finds out if a given table name exists in the database.
    def self.exists?(table_name)
      sql = "select * from pg_class where relname = '#{table_name}' and relkind = 'r'"
      !(ActiveRecord::Base.connection.execute(sql).entries.flatten.size == 0)
    end

    # The postgresql OID for this table.
    def oid
      @oid ||= fetch_oid
    end

    def oid!
      @oid = fetch_oid
      oid
    end

    # Returns an array of all foreign keys for this table, as <tt>Peegee::ForeignKey</tt> objects. 
    # The first time this method is called, foreign keys are retrieved from the database 
    # and cached in an instance variable. Subsequence calls will use the cached values. 
    # To force a lookup of foreign keys use the <tt>foreign_keys!</tt> method instead.
    def foreign_keys
      @foreign_keys ||= fetch_foreign_keys
    end

    def foreign_keys!
      @foreign_keys = fetch_foreign_keys
      @foreign_keys
    end

    # Returns an array of all dependent foreign keys for this table, as <tt>Peegee::ForeignKey</tt> objects. 
    # The first time this method is called, dependent foreign keys are retrieved from the database 
    # and cached in an instance variable. Subsequence calls will use the cached values. 
    # To force a lookup of dependent foreign keys use the <tt>dependent_foreign_keys!</tt> method instead.
    def dependent_foreign_keys
      @dependent_foreign_keys ||= fetch_dependent_foreign_keys
    end

    def dependent_foreign_keys!
      @dependent_foreign_keys = fetch_dependent_foreign_keys
      @dependent_foreign_keys
    end

    # Returns an array of primary keys for this table, as <tt>Peegee::PrimaryKey</tt> objects. 
    # The first time this method is called, primary keys are retrieved from the database 
    # and cached in an instance variable. Subsequence calls will use the cached values. 
    # To force a lookup of primary keys use the <tt>primary_key!</tt> method instead.
    def primary_key
      @primary_key ||= fetch_primary_key
    end

    def primary_key!
      @primary_key = fetch_primary_key
      @primary_key
    end

    # Returns an array of unique constraints for this table, as <tt>Peegee::UniqueConstraint</tt> objects. 
    # The first time this method is called, unique constraints are retrieved from the database 
    # and cached in an instance variable. Subsequence calls will use the cached values. 
    # To force a lookup of unique constraints use the <tt>unique_constraints!</tt> method instead.
    def unique_constraints
      @unique_constraints ||= fetch_unique_constraints
    end

    def unique_constraints!
      @unique_constraints = fetch_unique_constraints
      @unique_constraints
    end

    # Returns an array of indexes for this table, as <tt>Peegee::indexes</tt> objects. 
    # The first time this method is called, unique constraints are retrieved from the database 
    # and cached in an instance variable. Subsequence calls will use the cached values. 
    # To force a lookup of unique constraints use the <tt>indexes!</tt> method instead.
    def indexes
      @indexes ||= fetch_indexes
    end

    def indexes!
      @indexes = fetch_indexes
      @indexes
    end

    # Returns an array of <tt>Peegee::Column</tt> objects.
    # The first time this method is called, columns are retrieved from the database
    # and cached in an instance variable. Subsequent calls will use the cached values.
    # To force a lookup of this table's columns use the <tt>columns!</tt> method instead.
    def columns
      @columns ||= fetch_columns
    end

    def columns!
      @columns = fetch_columns
      @columns
    end

    # Returns the DDL for this table as a string.
    def ddl
      ddl = "create table #{@table_name} ( \n\t"
      columns_ddl = []
      columns.each do |column|
        column_ddl = []
        #name and type
        column_ddl << column.name + ' ' + column.type
        #not null?
        column_ddl << 'NOT NULL' if column.not_null
        #add modifiers:
        column_ddl << 'DEFAULT ' + column.default if column.has_default
        columns_ddl << column_ddl.join(' ')
      end
      ddl += columns_ddl.join(",\n\t") + "\n )"
      ddl.gsub('\\','')
    end

    # Returns a human readable description of this table
    def to_s
      description = "Table: #{@table_name}\n"
      description += "Columns:\n\t"
      columns.each do |column|
        column_desc = []
        #name and type
        column_desc << column.name + "\t" + column.type
        #not null?
        column_desc << 'NOT NULL' if column.not_null
        #add modifiers:
        column_desc << 'DEFAULT: ' + column.default if column.has_default
        description << column_desc.join("\n\t")
      end
      description += "Indexes:\n\t" if indexes.size > 0
      indexes_desc = []
      indexes.each do |index|
        indexes_desc << index.index_name
      end
      description += indexes_desc.join("\n\t")
      description += "Foreign Keys:\n\t" if foreign_keys.size > 0
      foreign_keys_desc = []
      foreign_keys.each do |fk|
        foreign_keys_desc << fk.foreign_key_name
      end
      description += foreign_keys_desc.join("\n\t")
      description += "Dependent Foreign Keys:\n\t" if dependent_foreign_keys.size > 0
      dependent_foreign_keys_desc = []
      dependent_foreign_keys.each do |dfk|
        dependent_foreign_keys_desc << dfk.foreign_key_name
      end
      description += dependent_foreign_keys_desc.join("\n\t")
      description
    end


    private
      # Retrieves this table's OID from the database.
      def fetch_oid
        sql = <<-END_SQL
        SELECT c.oid 
         FROM pg_catalog.pg_class c 
              LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace 
         WHERE c.relname ~ '^(#{@table_name})$'
           AND pg_catalog.pg_table_is_visible(c.oid)
        END_SQL
        return ActiveRecord::Base.connection.execute(sql).entries[0]
      end

      # Retrieves this table's primary key from the database.
      def fetch_primary_key
        sql = <<-END_SQL
          select  conname 
            , pg_get_constraintdef(pk.oid, true) as foreign_key 
            from pg_catalog.pg_constraint pk 
              inner join pg_class c 
                on c.oid = pk.conrelid 
            where contype = 'p' 
            and c.oid = '#{@table_name}'::regclass
        END_SQL
        raw_pks = ActiveRecord::Base.connection.execute(sql).entries
        return raw_pks.collect do  |pk|
          Peegee::ForeignKey.new(#TODO: Consider passing table object (self)
                                 :table_name => @table_name,
                                 :constraint_name => pk[0],
                                 :constraint_def => pk[1])
        end
      end

      # Retrieves this table's unique constraints from the database.
      def fetch_unique_constraints
        sql = <<-END_SQL
           select  conname
             , pg_get_constraintdef(uc.oid, true) as foreign_key
             from pg_catalog.pg_constraint uc
             inner join pg_class c 
             on c.oid = uc.conrelid
             where contype = 'u'
             and c.oid = '#{@table_name}'::regclass 
        END_SQL
        raw_ucs = ActiveRecord::Base.connection.execute(sql).entries
        return raw_ucs.collect do  |uc|
          Peegee::UniqueConstraint.new(#TODO: Consider passing table object (self)
                                 :table_name => @table_name,
                                 :constraint_name => uc[0],
                                 :constraint_def => uc[1])
        end
      end

      # Retrieves this table's foreign keys from the database.
      def fetch_foreign_keys
        sql = <<-END_SQL
          select  conname 
            , pg_get_constraintdef(fk.oid, true) as foreign_key
            from pg_catalog.pg_constraint fk
              inner join pg_class c
                on c.oid = fk.conrelid
            where contype = 'f'
            and c.oid = '#{@table_name}'::regclass
        END_SQL
        raw_fks = ActiveRecord::Base.connection.execute(sql).entries
        return raw_fks.collect do  |fk|
          Peegee::ForeignKey.new(#TODO: Consider passing table object (self)
                                 :table_name => @table_name,
                                 :constraint_name => fk[0],
                                 :constraint_def => fk[1])
        end
      end

      # Retrieves this table's dependent foreign keys from the database.
      # A dependent foreign key, is any foreign key that references this table.
      def fetch_dependent_foreign_keys
        sql = <<-END_SQL
          select pg_constraint.conname,
            dep_table.relname, 
            pg_get_constraintdef(pg_constraint.oid, true)
            from pg_constraint
              inner join pg_class dep_table on pg_constraint.conrelid = dep_table.oid
              where pg_constraint.confrelid = '#{@table_name}'::regclass;
        END_SQL
        raw_dpfks = ActiveRecord::Base.connection.execute(sql).entries
        return raw_dpfks.collect do |dpfk|
          Peegee::ForeignKey.new(#TODO: Consider passing table object (self)
                                 :table_name => dpfk[1],
                                 :constraint_name => dpfk[0],
                                 :constraint_def => dpfk[2])
        end
      end

      # Retrieves indexes for this table from the database.
      def fetch_indexes
        sql = <<-SQL_END
          SELECT pg_get_indexdef(i.indexrelid, 0, true) as index_definition 
          , c2.relname as index_name 
          , i.indisclustered 
          FROM pg_catalog.pg_class c
            inner join pg_catalog.pg_index i
              on c.oid = i.indrelid
            inner join pg_catalog.pg_class c2
              on i.indexrelid = c2.oid
          WHERE c.oid = '#{@table_name}'::regclass 
        SQL_END
        #"AND i.indisprimary = false" #don't get primary key constraints...
        indexes = ActiveRecord::Base.connection.execute(sql).entries
        return indexes.collect do |i| 
          Peegee::Index.new(:table_name => @table_name,
                            :index_name => i[1],
                            :clustered => (i[2] == 't' ? true : false),
                            :def => i[0])
          end
      end

      def fetch_columns
        sql = <<-END_SQL
          select a.attname as name
            , pg_catalog.format_type(a.atttypid, a.atttypmod) as type
            , a.attnum as number
            , a.attnotnull as not_null
            , a.atthasdef as has_default
            , substring(pg_catalog.pg_get_expr(d.adbin, d.adrelid) for 128)
          from pg_attribute a
          left outer join pg_attrdef d
            on a.attrelid = d.adrelid
            and a.attnum = d.adnum
          where a.attrelid = '#{@table_name}'::regclass
          and not a.attisdropped
          and a.attnum > 0
          order by a.attnum
        END_SQL
        ActiveRecord::Base.connection.execute(sql).entries.collect do |c|
          Peegee::Column.new(:name => c[0],
                             :type => c[1],
                             :table_name => @table_name,
                             :number => c[2],
                             :not_null => c[3] == 't' ? true : false,
                             :has_default => c[4] == 't' ? true : false,
                             :default => c[5])
        end
      end
  end
end
