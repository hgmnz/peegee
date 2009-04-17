require 'spec/spec_helper'

shared_examples_for 'all specs that call find on an existing index' do
  before(:each) do
    @index_name = 'login'
  end
  it 'should return the Peegee::Index object' do
    Peegee::Index.find(@index_name).should be_kind_of(Peegee::Index)
  end
end

describe 'Peegee::Index' do

  before(:all) do
    @peegee_helper = PeegeeHelper.new
    @peegee_helper.reset
  end

  describe 'calling the find method' do
    describe 'when the index does not exist' do
      it 'should return nil' do
        Peegee::Index.find('foo_bar_garbage').should be_nil
      end
    end

    describe 'when the index exists' do
      it_should_behave_like 'all specs that call find on an existing index'
    end
  end


  describe 'calling the find! method' do
    describe 'when the index does not exist' do
      it 'should raise a IndexNotFoundError' do
        lambda { 
          Peegee::Index.find!('foo_bar_garbage') 
        }.should raise_error(
          Peegee::IndexNotFoundError
        )
      end
    end

    describe 'when the index exists' do
      it_should_behave_like 'all specs that call find on an existing index'
    end

  end

end
