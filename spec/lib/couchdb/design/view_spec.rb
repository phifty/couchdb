require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "lib", "couchdb", "design", "view"))

describe CouchDB::Design::View do

  before :each do
    @database = mock CouchDB::Database
    @views_proxy = mock CouchDB::Design::ViewsProxy, :<< => nil
    @design = mock CouchDB::Design, :database => @database, :url => "http://host:1234/test/_design/test_design", :views => @views_proxy

    @view = described_class.new @design, "test_view", "test_map", "test_reduce"
  end

  describe "initialize" do

    it "should set the design" do
      @view.design.should == @design
    end

    it "should set the name" do
      @view.name.should == "test_view"
    end

    it "should set the map function" do
      @view.map.should == "test_map"
    end

    it "should set the reduce function" do
      @view.reduce.should == "test_reduce"
    end

    it "should add the view to the design" do
      @views_proxy.should_receive(:<<).with(@view)
      @view.send :initialize, @design, "test_view", "test_map", "test_reduce"
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

  describe "collection" do

    it "should return nil if design is nil" do
      @view.design = nil
      @view.collection.should be_nil
    end

    it "should return a collection with the database of the design" do
      collection = @view.collection
      collection.database.should == @database
    end

    it "should return a collection with the url of the view" do
      collection = @view.collection
      collection.url.should == @view.url
    end

    it "should return a collection with the given options" do
      collection = @view.collection :test => "test value"
      collection.options.should == { :test => "test value" }
    end

  end

  describe "url" do

    it "should return nil if design is nil" do
      @view.design = nil
      @view.url.should be_nil
    end

    it "should return the url" do
      @view.url.should == "http://host:1234/test/_design/test_design/_view/test_view"
    end

  end

end
