require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe CouchDB::Database do

  before :each do
    @server = make_test_server
    @database = described_class.new @server, "test"
  end

  describe "create!" do

    before :each do
      @database.delete_if_exists!
    end

    it "should create the database" do
      @database.create!
      @database.exists?.should be_true
    end

  end

  describe "delete!" do

    before :each do
      @database.create_if_missing!
    end

    it "should delete the database" do
      @database.delete!
      @database.exists?.should be_false
    end

  end

  describe "information" do

    before :each do
      @database.create_if_missing!
    end

    it "should return information about the database" do
      @database.information.should be_instance_of(Hash)
    end

  end

  describe "documents" do

    it "should return a collection" do
      @database.documents.should be_instance_of(CouchDB::Collection)
    end

  end

end
