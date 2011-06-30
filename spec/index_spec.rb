require 'spec_helper'

describe Peegee::Index, "creating SQL for a concurrent index" do
  let(:table_name) { "users" }
  let(:column) { "name" }

  let(:indexerizer) do
    Peegee::Index.new(
      :table_name => table_name,
      :column => column,
      :options => {:concurrently => true})
  end

  it "produces the proper SQL" do
    indexerizer.create_sql.should == %{CREATE  INDEX CONCURRENTLY "index_#{table_name}_on__#{column}_auto" ON "#{table_name}" ("#{column}"  ) }
  end

  it "is to be run outside of a transaction" do
    indexerizer.should be_run_outside_transaction
  end
end

describe Peegee::Index, "creating SQL for an index specifying a tablespace" do
  let(:table_name) { "users" }
  let(:column) { "name" }
  let(:tablespace) { "indexspace" }

  let(:indexerizer) do
    Peegee::Index.new(
      :table_name => table_name,
      :column => column,
      :options => {:tablespace => tablespace})
  end

  it "produces the proper SQL" do
    indexerizer.create_sql.should == %{CREATE  INDEX  "index_#{table_name}_on__#{column}_auto" ON "#{table_name}" ("#{column}"  ) TABLESPACE #{tablespace}}
  end

  it "is to be run inside of a transaction" do
    indexerizer.should_not be_run_outside_transaction
  end
end
