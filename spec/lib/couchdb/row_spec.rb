require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'helper'))

describe CouchDB::Row do

  before :each do
    @database = mock CouchDB::Database
    @hash = {
      'id' => 'test id',
      'key' => 'test key',
      'value' => 'test value',
      'doc' => {
        '_id' => 'test doc id',
        'name' => 'test doc name'
      }
    }
    @row = described_class.new @database, @hash
  end

  describe 'initialize' do

    it 'should assign the database' do
      @row.database.should == @database
    end

    it 'should assign the id' do
      @row.id.should == 'test id'
    end

    it 'should assign the key' do
      @row.key.should == 'test key'
    end

    it 'should assign the id' do
      @row.value.should == 'test value'
    end

  end

  describe 'document' do

    it 'should return a document' do
      @row.document.should be_instance_of(CouchDB::Document)
    end

    it 'should return a document with the right database' do
      @row.document.database.should == @database
    end

    it 'should return a document with the right properties' do
      @row.document.id.should == 'test doc id'
      @row.document['name'].should == 'test doc name'
    end

  end

end
