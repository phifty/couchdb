require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe CouchDB::Server do

  before :each do
    @server = CouchDB::Server.new
  end

  describe "information" do

    it "should return some information about the server" do
      @server.information.should == { "couchdb" => "Welcome", "version" => "1.0.1" }
    end

  end

  describe "statistics" do

    it "should return some statistics about the server" do
      @server.statistics.should be_instance_of(Hash)
    end

  end

  describe "database_names" do

    it "should return the names of all databases" do
      @server.database_names.should be_instance_of(Array)
    end

  end

  describe "uuids" do

    it "should return the given number of generated uuids" do
      uuids = @server.uuids 4
      uuids.should be_instance_of(Array)
      uuids.size.should == 4
    end

  end

end
