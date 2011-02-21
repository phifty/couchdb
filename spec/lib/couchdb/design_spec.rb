require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))

describe CouchDB::Design do

  before :each do
    @database = mock CouchDB::Database, :url => "http://host:1234/test"

    @design = described_class.new @database, "test_design"
  end

  describe "initialize" do

    it "should set the database" do
      @design.database.should == @database
    end

    it "should set the id" do
      @design.id.should == "test_design"
    end

    it "should set the attributes" do
      @design.language.should == "javascript"
    end

  end

  describe "id" do

    it "should return the id without _design prefix" do
      @design["_id"] = "_design/test_design"
      @design.id.should == "test_design"
    end

  end

  describe "id=" do

    it "should add the _design prefix to the id" do
      @design.id = "test_design"
      @design["_id"].should == "_design/test_design"
    end

  end

  describe "language" do

    it "should return the langauge field" do
      @design["language"] = "test_language"
      @design.language.should == "test_language"
    end

  end

  describe "language=" do

    it "should set the langauge field" do
      @design.language = "test_language"
      @design["language"].should == "test_language"
    end

  end

  describe "url" do

    it "should return the database url combined with the _design prefix and the id" do
      url = @design.url
      url.should == "http://host:1234/test/_design/test_design"
    end

  end

  describe "views" do

    before :each do
      @view_hash = { "test_view" => { "map" => "test_map", "reduce" => "test_reduce" } }
      @view = mock CouchDB::Design::View, :to_hash => @view_hash
    end

    describe "<<" do

      it "should add a view" do
        @design.views << @view
        @design["views"].should == @view_hash
      end

    end

    describe "[]" do

      before :each do
        CouchDB::Design::View.stub(:new).and_return(@view)
        @design.views << @view
      end

      it "should initialize a new view" do
        CouchDB::Design::View.should_receive(:new).with(@design, "test_view", "test_map", "test_reduce").and_return(@view)
        @design.views[:test_view]
      end

      it "should return the new view" do
        @design.views[:test_view].should == @view
      end

      it "should return nil if view doesn't exists" do
        @design.views[:invalid].should be_nil
      end

    end

  end

end
