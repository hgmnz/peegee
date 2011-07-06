Feature: Creating a table with some constraints

  Background:
    Given I create and configure the "peegee_test" rails app
    And I run `script/rails generate model User name:string active:boolean`

@announce
  Scenario: Creating a table with a fkey
    Given I run `script/rails generate migration create_comments_by_user`
    And I implement the latest migration as:
    """
      def self.up
        create_table :comments do |t|
          t.references :user
        end
      end
    """
    Given I run `bundle exec rake db:migrate --trace`
    When I write to "app/models/comment.rb" with:
    """
    class Comment < ActiveRecord::Base
      belongs_to :user
    end
    """
    When I create a Comment
    Then it should have the following error on user_id:
    """
    must belong to an existing user
    """
