Feature: Adding PostgreSQL specific indexes in a Rails migration
  As a developer
  I can add PostgreSQL index types in a migration
  So that my application has better performance

  Background:
    Given I create and configure the "peegee_test" rails app
    And I run `script/rails generate model User name:string active:boolean`

  Scenario: Adding a partial index
    Given I run `script/rails generate migration add_index_to_active_users`
    And I implement the latest migration as:
    """
      def self.up
        add_index :users, :name, :name => 'users_name_where_active_true', :where => 'active = true'
      end
    """
    And I run `bundle exec rake db:migrate --trace`
    Then the "users" table should have the following index:
      | CREATE INDEX users_name_where_active_true ON users USING btree (name) WHERE active = true |

  Scenario: Adding an expression index
    Given I run `script/rails generate migration add_index_on_date_created_at`
    And I implement the latest migration as:
    """
      def self.up
        add_index :users, :name => 'users_created_at_date' do |i|
          i.expression "DATE(created_at)"
        end
      end
    """
    And I run `bundle exec rake db:migrate`
    Then the "users" table should have the following index:
      | CREATE INDEX users_created_at_date ON users USING btree (date(created_at)) |

  Scenario: Adding an expression partial index
    Given I run `script/rails generate migration add_index_on_date_created_at`
    And I implement the latest migration as:
    """
      def self.up
        add_index :users, :name => 'users_created_at_date_where_active_true', :where => 'active = true' do |i|
          i.expression "DATE(created_at)"
        end
      end
    """
    And I run `bundle exec rake db:migrate`
    Then the "users" table should have the following index:
      | CREATE INDEX users_created_at_date_where_active_true ON users USING btree (date(created_at)) WHERE active = true |

  Scenario: Adding a sort order to an index
    Given I run `script/rails generate migration add_index_on_users_name_asc`
    And I implement the latest migration as:
    """
      def self.up
        add_index :users, :name => 'users_name_asc_active_desc' do |i|
          i.column :name,    :asc
          i.column :active, :desc
        end
      end
    """
    And I run `bundle exec rake db:migrate --trace`
    Then the "users" table should have the following index:
      | CREATE INDEX users_name_asc_active_desc ON users USING btree (name, active DESC) |

  Scenario: Adding an index with a sort order but with nulls sorted specifically
    Given I run `script/rails generate migration add_index_on_users_nulls_sorted`
    And I implement the latest migration as:
    """
      def self.up
        add_index :users, :name => 'users_name_asc_active_desc' do |i|
          i.column :name,    :asc, :nulls => :first
          i.column :active, :desc, :nulls => :last
        end
      end
    """
    And I run `bundle exec rake db:migrate --trace`
    Then the "users" table should have the following index:
      | CREATE INDEX users_name_asc_active_desc ON users USING btree (name NULLS FIRST, active DESC NULLS LAST) |

  Scenario: Adding a unique index
    Given I run `script/rails generate migration add_unique_index_to_active_users`
    And I implement the latest migration as:
    """
      def self.up
        add_index :users, :name, :name => 'users_name_where_active_true', :where => 'active = true', :unique => true
      end
    """
    And I run `bundle exec rake db:migrate --trace`
    Then the "users" table should have the following index:
      | CREATE UNIQUE INDEX users_name_where_active_true ON users USING btree (name) WHERE active = true |
