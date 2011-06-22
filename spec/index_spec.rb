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

  subject { indexerizer.create_sql }

  it "produces the proper SQL" do
    should == %{CREATE  INDEX CONCURRENTLY "index_#{table_name}_on__#{column}_auto" ON "#{table_name}" ("#{column}"  )}
  end
end
