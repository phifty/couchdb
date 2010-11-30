require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))

describe CouchDB::Collection do

  before :each do
    Transport::JSON.stub(:request)
    @collection = described_class.new "http://host:1234/test/_all_docs"
  end

  describe "initialize" do

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
          :parameters => { :include_docs => true, :limit => 0 },
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
      CouchDB::Row.should_receive(:new).with(@row_hash).and_return(@row)
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

end
