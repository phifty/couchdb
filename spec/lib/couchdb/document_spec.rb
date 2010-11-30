require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))

describe CouchDB::Document do

  before :each do
    Transport::JSON.stub(:request)
    @database = mock CouchDB::Database, :url => "http://host:1234/test"
    @document = described_class.new @database, "_id" => "test_document_1"
  end

  describe "[]" do

    it "should return the requested property" do
      @document[:test] = "test value"
      @document["test"].should == "test value"
    end

  end

  describe "[]=" do

    it "should set the documents content" do
      @document["test"] = "test value"
      @document[:test].should == "test value"
    end

  end

  describe "id" do

    it "should return the _id property" do
      @document["_id"] = "test_document_2"
      @document.id.should == "test_document_2"
    end

  end

  describe "id=" do

    it "should set the _id property" do
      @document.id = "test_document_2"
      @document["_id"].should == "test_document_2"
    end

  end

  describe "rev" do

    it "should return the _rev property" do
      @document["_rev"] = 1
      @document.rev.should == 1
    end

  end

  describe "rev=" do

    it "should set the _id property" do
      @document.rev = 1
      @document["_rev"].should == 1
    end

  end

  describe "each_property" do

    it "should call the given block for each property" do
      @document["test"] = "test value"
      result = nil
      @document.each_property{ |key, value| result = [ key, value ] }
      result.should == [ "test", "test value" ]
    end

  end

  describe "==" do

    it "should be true if the id's of the models are equal" do
      @document.should == described_class.new(@database, "_id" => "test_document_1")
    end

    it "should be false if the id's of the models are not equal" do
      @document.should_not == described_class.new(@database, "_id" => "invalid")
    end

  end

  describe "new?" do

    it "should be true on new model" do
      described_class.new(@database).should be_new
    end

    it "should be false on existing model" do
      @document.rev = "valid"
      @document.should_not be_new
    end

  end

  describe "exists?" do

    it "should request the document to check it's existance" do
      Transport::JSON.should_receive(:request).with(
        :get,
        "http://host:1234/test/test_document_1",
        :expected_status_code => 200
      )
      @document.exists?
    end

    it "should return true if document is existing" do
      @document.exists?.should be_true
    end

    it "should return false if transport returns a 404" do
      Transport::JSON.stub(:request).and_raise(Transport::UnexpectedStatusCodeError.new(404))
      @document.exists?.should be_false
    end

    it "should pass all unexpected status errors that are different from 404" do
      Transport::JSON.stub(:request).and_raise(Transport::UnexpectedStatusCodeError.new(500))
      lambda do
        @document.exists?
      end.should raise_error(Transport::UnexpectedStatusCodeError)
    end

  end

  describe "load" do

    it "should request the document" do
      Transport::JSON.should_receive(:request).with(
        :get,
        "http://host:1234/test/test_document_1",
        :expected_status_code => 200
      )
      @document.load
    end

    it "should set the properties with the result" do
      Transport::JSON.stub(:request).and_return({
        "_id" => "test_document_2",
        "_rev" => 1
      })
      @document.load
      @document.id.should == "test_document_2"
      @document.rev.should == 1
    end

    it "should raise an NotFoundError if the transport returns a 404 status code" do
      Transport::JSON.stub(:request).and_raise(Transport::UnexpectedStatusCodeError.new(404))
      lambda do
        @document.load
      end.should raise_error(described_class::NotFoundError)
    end

  end

  describe "save" do

    context "on a new model" do

      before :each do
        Transport::JSON.stub(:request).and_return({
          "id" => "test_document_2",
          "rev" => 1
        })
        @document = described_class.new @database
      end

      it "should request the create of the doucment" do
        Transport::JSON.should_receive(:request).with(
          :post,
          "http://host:1234/test",
          :body => { },
          :expected_status_code => 201
        ).and_return({
          "id" => "test_document_2",
          "rev" => 1
        })
        @document.save
      end

      it "should return true if the model has been saved" do
        @document.save.should be_true
      end

      it "should set the document id and rev" do
        @document.save
        @document.id.should == "test_document_2"
        @document.rev.should == 1
      end

      it "should return false on wrong status code" do
        Transport::JSON.stub(:request).and_raise(Transport::UnexpectedStatusCodeError.new(404))
        @document.save.should be_false
      end

    end

    context "on an existing model" do

      before :each do
        Transport::JSON.stub(:request).and_return({
          "rev" => 2
        })
        @document.rev = 1
      end

      it "should request the update of the doucment" do
        Transport::JSON.should_receive(:request).with(
          :put,
          "http://host:1234/test/test_document_1",
          :body => { "_id" => "test_document_1", "_rev" => 1 },
          :expected_status_code => 201
        ).and_return({
          "rev" => 2
        })
        @document.save
      end

      it "should return true if the model has been updated" do
        @document.save.should be_true
      end

      it "should set the document rev" do
        @document.save
        @document.rev.should == 2
      end

      it "should return false on wrong status code" do
        Transport::JSON.stub!(:request).and_raise(Transport::UnexpectedStatusCodeError.new(404))
        @document.save.should be_false
      end

    end

  end

  describe "destroy" do

    describe "on a new model" do

      before :each do
        @document = described_class.new @database
      end

      it "should return false" do
        @document.destroy.should be_false
      end

    end

    describe "on an existing model" do

      before :each do
        @document.rev = 1
      end

      it "should request the descroy of the doucment" do
        Transport::JSON.should_receive(:request).with(
          :delete,
          "http://host:1234/test/test_document_1",
          :headers => { "If-Match" => 1 },
          :expected_status_code => 200
        )
        @document.destroy
      end

      it "should return true if the model has been destroyed" do
        @document.destroy.should be_true
      end

      it "should raise NotFoundError on wrong status code" do
        Transport::JSON.stub!(:request).and_raise(Transport::UnexpectedStatusCodeError.new(404))
        lambda do
          @document.destroy
        end.should raise_error(described_class::NotFoundError)
      end

      it "should be new afterwards" do
        @document.destroy
        @document.should be_new
      end

    end

  end

  describe "create" do

    before :each do
      @document = mock described_class, :save => true
      described_class.stub(:new).and_return(@document)
    end

    it "should initialize the document" do
      described_class.should_receive(:new).with(@database).and_return(@document)
      described_class.create @database
    end

    it "should save the document" do
      @document.should_receive(:save).and_return(true)
      described_class.create @database
    end

    it "should return the document if save was successful" do
      described_class.create(@database).should == @document
    end

    it "should return bil if save failed" do
      @document.stub(:save).and_return(false)
      described_class.create(@database).should be_nil
    end

  end

end
