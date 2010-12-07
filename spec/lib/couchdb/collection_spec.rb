require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))

describe CouchDB::Collection do

  before :each do
    Transport::JSON.stub(:request)
    @database = mock CouchDB::Database

    @collection = described_class.new @database, "http://host:1234/test/_all_docs"
  end

  describe "initialize" do

    it "should set the database" do
      @collection.database.should == @database
    end

    it "should set the url" do
      @collection.url.should == "http://host:1234/test/_all_docs"
    end

  end

  describe "total_count" do

    before :each do
      Transport::JSON.stub(:request).and_return({ "total_rows" => 1 })
    end

    describe "without a previously performed fetch" do

      it "should perform a meta fetch (with a limit of zero)" do
        Transport::JSON.should_receive(:request).with(
          :get,
          "http://host:1234/test/_all_docs",
          :parameters => { :limit => 0 },
          :encode_parameters => true,
          :expected_status_code => 200
        ).and_return({ "total_rows" => 1 })
        @collection.total_count
      end

      it "should return the total count" do
        @collection.total_count.should == 1
      end

    end

    describe "with a previously performed fetch" do

      before :each do
        @collection.first # perform the fetch
      end

      it "should not perform another fetch" do
        Transport::JSON.should_not_receive(:request)
        @collection.total_count
      end

      it "should return the total count" do
        @collection.total_count.should == 1
      end

    end

  end

  describe "first" do

    before :each do
      @row_hash = mock Hash
      Transport::JSON.stub(:request).and_return({
        "total_rows" => 1,
        "rows" => [ @row_hash ]
      })
      @row = mock CouchDB::Row
      CouchDB::Row.stub(:new).and_return(@row)
    end

    it "should initialize the row with the row hash" do
      CouchDB::Row.should_receive(:new).with(@database, @row_hash).and_return(@row)
      @collection.first
    end

    it "should return the first element of the fetched result" do
      @collection.first.should == @row
    end

    it "should update the total count" do
      @collection.first
      @collection.total_count.should == 1
    end

  end

  describe "documents" do

    before :each do
      @document = mock CouchDB::Document
      @row = mock CouchDB::Row, :document => @document
      @collection.stub(:map).and_yield(@row).and_return([ @document ])
    end

    it "should add the include docs options" do
      @collection.documents.first
      @collection.options.should include(:include_docs => true)
    end

    it "should map the rows to documents" do
      @collection.should_receive(:map).and_yield(@row).and_return([ @document ])
      @collection.documents.first
    end

    it "should return the selected row's document" do
      document = @collection.documents.first
      document.should == @document
    end

  end

end
