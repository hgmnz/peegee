## Peegee
Peegee aims to bring better support for PostgreSQL to ActiveRecord. Peegee is under active development.

###Indexes

Peegee adds support for some indexing extensions allowed by Postgres. You can run these in your migrations.

#### Partial indexes
```ruby
  add_index :users, :column, :where => 'active = true'
```

#### Expression indexes
```ruby
  add_index :users, :name => 'users_created_at_date' do |i|
    i.expression 'DATE(created_at)'
  end
```

#### Sorted indexes
```ruby
  add_index :users, :name => 'users_created_at_date' do |i|
    i.column :name, :asc
    i.column :active, :desc
  end
```

#### Using [CONCURRENTLY](http://www.postgresql.org/docs/9.0/static/sql-createindex.html#SQL-CREATEINDEX-CONCURRENTLY)
```ruby
  add_index :users, :name, :name => 'users_name', :concurrently => true
```

### License

Peegee is distributed under the MIT license.

Copyright 2011 - Harold Giménez and Mike Burns
