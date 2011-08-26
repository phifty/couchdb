require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe CouchDB::Document do

  before :each do
    @server = make_test_server
    @database = CouchDB::Database.new @server, "test"
    @database.delete_if_exists!
    @database.create_if_missing!

    @document = described_class.new @database, "_id" => "test_document_1", "test" => "test value"
    @document.save
  end

  after :each do
    @document.destroy
  end

  describe "load" do

    it "should load the document's properties" do
      @document["test"] = nil
      @document.load
      @document["test"].should == "test value"
    end

  end

  describe "save" do

    context "on a new model" do

      before :each do
        begin
          @document.load
          @document.destroy
        rescue described_class::NotFoundError
        end
      end

      it "should create the document" do
        lambda do
          @document.save
        end.should change(@document, :new?).from(true).to(false)
      end

    end

    context "on an existing model" do

      it "should update the document" do
        lambda do
          @document["test"] = "another test value"
          @document.save
        end.should change(@document, :rev)
      end

    end

  end

  describe "destroy" do

    it "should destroy the document" do
      lambda do
        @document.destroy
      end.should change(@document, :exists?).from(true).to(false)
    end

    it "should set the document's state to new" do
      lambda do
        @document.destroy
      end.should change(@document, :new?).from(false).to(true)
    end

  end

end
