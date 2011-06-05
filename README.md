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
  add_index :users, { :expression => 'DATE(created_at)' }, :name => 'users_created_at_date'
```

### License

Peegee is distributed under the MIT license.

Copyright 2011 - Harold Giménez
