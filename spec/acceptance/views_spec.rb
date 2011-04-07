require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

describe "views" do

  before :each do
    @server = CouchDB::Server.new
    @database = CouchDB::Database.new @server, "test"
    @database.delete_if_exists!
    @database.create_if_missing!

    @document_one = CouchDB::Document.new @database, "_id" => "test_document_1", "category" => "one"
    @document_one.save
    @document_two = CouchDB::Document.new @database, "_id" => "test_document_2", "category" => "one"
    @document_two.save
    @document_three = CouchDB::Document.new @database, "_id" => "test_document_3", "category" => "two"
    @document_three.save

    @design = CouchDB::Design.new @database, "design_1"
    @view = CouchDB::Design::View.new @design, "view_1",
      "function(document) { emit([ document['category'], document['_id'] ], 1); }"
    @design.save
  end

  describe "selecting a view by it's name" do

    it "should return the right view" do
      view = @design.views[:view_1]
      view.should be_instance_of(CouchDB::Design::View)
      view.map.should == @view.map
      view.reduce.should == @view.reduce
    end

  end

  describe "collection" do

    it "should return a collection including the right rows" do
      collection = @view.collection :startkey => [ "one", nil ], :endkey => [ "one", { } ]
      collection.size.should == 2
      collection[0].id.should == "test_document_1"
      collection[0].key.should == [ "one", "test_document_1" ]
      collection[0].value.should == 1
      collection[1].id.should == "test_document_2"
      collection[1].key.should == [ "one", "test_document_2" ]
      collection[1].value.should == 1
    end

    it "should return a collection including the right documents" do
      collection = @view.collection :startkey => [ "one", nil ], :endkey => [ "one", { } ]
      collection.documents.should include(@document_one)
      collection.documents.should include(@document_two)
      collection.documents.should_not include(@document_three)
    end

  end

  describe "reduced collection" do

    before :each do
      @view = CouchDB::Design::View.new @design, "view_2",
        "function(document) { emit(document['category'], 1); }",
        "function(key, values, rereduce) { return sum(values); }"
      @design.save
    end

    it "should return a collection including the right rows" do
      collection = @view.collection :key => "one", :group => true
      collection.size.should == 1
      collection[0].id.should be_nil
      collection[0].key.should == "one"
      collection[0].value.should == 2
    end

  end

  describe "all documents collection" do

    it "should return a collection with all documents of the database" do
      collection = @database.documents
      collection.size.should == 4 # three documents plus the design
    end

  end

end
