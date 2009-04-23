require 'spec/spec_helper'

describe 'Peegee::Table' do

  before :all do
    @peegee_helper = PeegeeHelper.new
    @peegee_helper.reset
  end

  describe 'when calling find' do

    it 'should understand hash parameters with a :table_name key' do
      the_table = Peegee::Table.find(:table_name => 'posts')
      the_table.should be_kind_of(Peegee::Table)
      the_table.table_name.should == 'posts'
    end

    it 'should understand a string parameter and assign it to table_name)' do
      the_table = Peegee::Table.find('posts')
      the_table.should be_kind_of(Peegee::Table)
      the_table.table_name.should == 'posts'
    end
    
    describe 'when it has been called before for the same table' do

      before(:each) do
        @posts1 = Peegee::Table.find('posts')
        @posts2 = Peegee::Table.find('posts')
      end
      it 'should return the same object' do
        @posts1.should == @posts2
      end

      describe 'when retreiving associated foreign keys' do
        before(:each) do
          
        end

        it 'should return the same foreign keys for both objects' do

        end
      end
    end

    describe 'when the table does not exist in the DB' do
      it 'should raise an error' do
        lambda { 
          Peegee::Table.find(:table_name => 'foo_bar_baz') 
        }.should raise_error(
          Peegee::TableNotFoundError
        )
      end
    end

    describe 'when the table exists on the DB' do
      before :each do
        @users_table = Peegee::Table.find(:table_name => 'users')
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

    before(:each) do
      Peegee::Database.forget_table_register!
      @peegee_helper.configure_peegee
      3.times { Factory.create(:user) }
      @users = User.all
      @users_table = Peegee::Table.find('users')
      @foreign_keys = @users_table.foreign_keys!
      @dependent_foreign_keys = @users_table.dependent_foreign_keys!
      @primary_key = @users_table.primary_key!
      @unique_constraints = @users_table.unique_constraints!
      @indexes = @users_table.indexes!
    end

    after(:each) do
      User.delete_all
    end

    it 'should maintain all dependent foreign keys on the resulting table' do
      do_cluster
      @dependent_foreign_keys.each do |dfk|
        @users_table.dependent_foreign_keys!.select { |new_dfk| 
          new_dfk.foreign_key_name == dfk.foreign_key_name &&
          new_dfk.constraint_def == dfk.constraint_def &&
          new_dfk.table_name == dfk.table_name
        }.should_not be_empty
      end
      @users_table.dependent_foreign_keys.size.should == @dependent_foreign_keys.size
    end

    it 'should maintain all foreign keys on the resulting table' do
      do_cluster
      @foreign_keys.each do |fk|
        @users_table.foreign_keys!.select { |new_fk|
          new_fk.foreign_key_name == fk.foreign_key_name &&
          new_dfk.constraint_def == dfk.constraint_def &&
          new_dfk.table_name == dfk.table_name
        }.should_not be_empty
      end
      @users_table.foreign_keys.size.should == @foreign_keys.size
    end

    it 'should maintain all primary key on the resulting table' do
      do_cluster
      @users_table.primary_key!
      @primary_key.each do |pk|
        @users_table.primary_key!.should include(pk)
      end
      @users_table.primary_key.size.should == @primary_key.size
    end

    it 'should maintain all indexes on the resulting table' do
      do_cluster
      @indexes.each do |i|
        @users_table.indexes!.select { |new_i|
          new_i.table_name == i.table_name &&
          new_i.index_name == i.index_name &&
          new_i.clustered == i.clustered &&
          new_i.def == i.def
        }.should_not be_empty
      end
      @users_table.indexes.size.should == @indexes.size
    end

    it 'should maintain all of the data on the resulting table' do
      do_cluster
      @users.should == User.all
    end
  end
end
