require 'spec/spec_helper'

describe 'Peegee::Table' do

  before :all do
    @peegee_helper = PeegeeHelper.new
    @peegee_helper.reset
  end

  describe 'when creating a Peegee::Table object' do
    describe 'when the table does not exist in the DB' do
      it 'should raise an error' do
        lambda { 
          Peegee::Table.new(:table_name => 'foo') 
        }.should raise_error(
          Peegee::TableDoesNotExistError
        )
      end
    end

    describe 'when the table exists on the DB' do
      before :each do
        @users_table = Peegee::Table.new(:table_name => 'users')
      end
      it 'should create a Peegee::Table instance' do
        @users_table.should be_kind_of(Peegee::Table)
      end
    end
  end

  describe 'clustering a table' do

    def do_cluster
      @users_table.cluster
    end

    before :each do
      @peegee_helper.configure_peegee
      3.times { Factory.create(:user) }
      @users = User.all
      @users_table = Peegee::Table.new(:table_name => 'users')
      @foreign_keys = @users_table.foreign_keys
      @dependent_foreign_keys = @users_table.dependent_foreign_keys
      @primary_key = @users_table.primary_key
      @unique_constraints = @users_table.unique_constraints
      @indexes = @users_table.indexes
    end

    after :each do
      User.delete_all
    end

    it 'should maintain all foreign keys on the resulting table' do
      do_cluster
      @users_table.foreign_keys!
      @foreign_keys.each do |fk|
        @users_table.foreign_keys.should include(fk)
      end
      @users_table.foreign_keys.size.should == @foreign_keys.size
    end

    it 'should maintain all dependent foreign keys on the resulting table' do
      do_cluster
      @users_table.dependent_foreign_keys!
      @dependent_foreign_keys.each do |dpf|
        @users_table.dependent_foreign_keys.should include(dpf)
      end
      @users_table.dependent_foreign_keys.size.should == @dependent_foreign_keys.size
    end

    it 'should maintain all primary key on the resulting table' do
      do_cluster
      @users_table.primary_key!
      @primary_key.each do |pk|
        @users_table.primary_key.should include(pk)
      end
      @users_table.primary_key.size.should == @primary_key.size
    end

    it 'should maintain all indexes on the resulting table' do
      do_cluster
      @users_table.indexes!
      @indexes.each do |i|
        @users_table.indexes.should include(i)
      end
      @users_table.indexes.size.should == @indexes.size
    end

    it 'should maintain all of the data on the resulting table' do
      do_cluster
      @users.should == User.all
    end

  end
end
