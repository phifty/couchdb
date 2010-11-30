require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))

describe CouchDB::Row do

  before :each do
    @hash = {
      "id" => "test id",
      "key" => "test key",
      "value" => "test value",
      "doc" => {
        "_id" => "test doc id",
        "name" => "test doc name"
      }
    }
    @row = described_class.new @hash
  end

  describe "initialize" do

    it "should assign the id" do
      @row.id.should == "test id"
    end

    it "should assign the key" do
      @row.key.should == "test key"
    end

    it "should assign the id" do
      @row.value.should == "test value"
    end

    it "should assign the document" do
      @row.document.should == {
        "_id" => "test doc id",
        "name" => "test doc name"
      }
    end

  end

end
