require File.join(File.dirname(__FILE__), '..', 'helper')

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

      document = @database.documents.create :test => 'test value'
      p document
      @database.documents.destroy document
    end

    it 'should remove destroyed documents' do
      @database.compact!
      p @database.information
      @database.information[:compact_running].should be_true
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
      @database.documents.all.should be_instance_of(CouchDB::Collection)
    end

  end

end
