Feature: Adding PostgreSQL specific indexes in a Rails migration
  As a developer
  I can add PostgreSQL index types in a migration
  So that I can make better use of PostgreSQL indexes

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
      def self.down
        remove_index :users, :name
      end
    """
    And I run `bundle exec rake db:migrate`
    Then the "users" table should have the following index:
      | CREATE INDEX users_name_where_active_true ON users USING btree (name) WHERE active = true |

  Scenario: Adding an expression index
    Given I run `script/rails generate migration add_index_on_date_created_at`
    And I implement the latest migration as:
    """
      def self.up
        add_index :users, { :expression => "DATE(created_at)" }, :name => 'users_created_at_date'
      end
      def self.down
        remove_index :users, :name
      end
    """
    And I run `bundle exec rake db:migrate`
    Then the "users" table should have the following index:
      | CREATE INDEX users_created_at_date ON users USING btree (date(created_at)) |
