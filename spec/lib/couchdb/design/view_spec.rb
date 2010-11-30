require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "lib", "couchdb", "design", "view"))

describe CouchDB::Design::View do

  before :each do
    @design = mock CouchDB::Design, :url => "http://host:1234/test/_design/test_design"
    @view = CouchDB::Design::View.new @design, "test_view", "test_map", "test_reduce"
  end

  describe "initialize" do

    it "should set the name" do
      @view.name.should == "test_view"
    end

    it "should set the map function" do
      @view.map.should == "test_map"
    end

    it "should set the reduce function" do
      @view.reduce.should == "test_reduce"
    end

  end

  describe "to_hash" do

    it "should return a hash with all view data" do
      @view.to_hash.should == {
        "test_view" => {
          "map" => "test_map",
          "reduce" => "test_reduce"
        }
      }
    end

  end

  describe "url" do

    it "should return the url" do
      @view.url.should == "http://host:1234/test/_design/test_design/_view/test_view"
    end

  end

end
