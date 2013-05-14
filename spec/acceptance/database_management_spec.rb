require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe 'database management' do

  before :each do
    @server = make_test_server
    @database = make_test_database @server
  end

  describe 'creating a database' do

    before :each do
      @database.delete_if_exists!
    end

    it 'should create the database' do
      @database.create!
      @database.exists?.should be_true
    end

  end

  describe 'deleting a database' do

    before :each do
      @database.create_if_missing!
    end

    it 'should delete the database' do
      @database.delete!
      @database.exists?.should be_false
    end

  end

  describe 'compacting a database' do

    before :each do
      @database.delete_if_exists!
      @database.create_if_missing!

      @document = CouchDB::Document.new @database, '_id' => 'test_document_1', 'test' => 'test value'
      @document.save
      @document.destroy
    end

    it 'should remove destroyed documents' do
      @database.compact!
      @database.information['compact_running'].should be_true
    end

  end

  describe 'fetching information about a database' do

    before :each do
      @database.create_if_missing!
    end

    it 'should return information about the database' do
      @database.information.should be_instance_of(Hash)
    end

  end

  describe 'fetching all documents of a database' do

    it 'should return a collection' do
      @database.documents.should be_instance_of(CouchDB::Collection)
    end

  end

end
