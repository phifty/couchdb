require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))

describe CouchDB::Database do

  before :each do
    Transport::JSON.stub(:request)
    @server = mock CouchDB::Server, :url => "http://host:1234", :database_names => [ "test" ]

    @database = CouchDB::Database.new @server, "test"
  end

  describe "==" do

    it "should be true when comparing two equal databases" do
      @database.should == described_class.new(@server, "test")
    end

    it "should be false when comparing two different databases" do
      @database.should_not == described_class.new(@server, "different")
    end

  end

  describe "===" do

    it "should be true when comparing a database object with itself" do
      @database.should === @database
    end

    it "should be false when comparing a database object with another database object" do
      @database.should_not === described_class.new(@server, "test")
    end

  end

  describe "create!" do

    it "should request the create of the database" do
      Transport::JSON.should_receive(:request).with(
        :put,
        "http://host:1234/test",
        :expected_status_code => 201
      )
      @database.create!
    end

  end

  describe "create_if_missing!" do

    before :each do
      @database.stub(:create!)
    end

    it "should not call create! if the database exists" do
      @database.stub(:exists?).and_return(true)
      @database.should_not_receive(:create!)
      @database.create_if_missing!
    end

    it "should call create! if the database not exists" do
      @database.stub(:exists?).and_return(false)
      @database.should_receive(:create!)
      @database.create_if_missing!
    end

  end

  describe "delete!" do

    it "should delete the database" do
      Transport::JSON.should_receive(:request).with(
        :delete,
        "http://host:1234/test",
        :expected_status_code => 200
      )
      @database.delete!
    end

  end

  describe "delete_if_exists!" do

    before :each do
      @database.stub(:delete!)
    end

    it "should call delete! if the database exists" do
      @database.stub(:exists?).and_return(true)
      @database.should_receive(:delete!)
      @database.delete_if_exists!
    end

    it "should not call delete! if the database not exists" do
      @database.stub(:exists?).and_return(false)
      @database.should_not_receive(:delete!)
      @database.delete_if_exists!
    end

  end

  describe "informations" do

    it "should request database informations" do
      Transport::JSON.should_receive(:request).with(
        :get,
        "http://host:1234/test",
        :expected_status_code => 200
      ).and_return("result")
      @database.informations.should == "result"
    end

  end

  describe "exists?" do

    it "should be true" do
      @database.exists?.should be_true
    end

    it "should be false if no database with the given name exists" do
      database = described_class.new @server, "invalid"
      database.exists?.should be_false
    end

  end

  describe "documents" do

    it "should return a collection" do
      pending
      @database.documents.should be_instance_of(CouchDB::Collection)
    end

  end

end
