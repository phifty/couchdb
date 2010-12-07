require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

describe "views" do

  before :each do
    @server = CouchDB::Server.new
    @database = CouchDB::Database.new @server, "test"
    @database.delete_if_exists!
    @database.create_if_missing!

    @document_one = CouchDB::Document.new @database, "_id" => "test_document_1", "category" => "one"
    @document_one.save
    @document_two = CouchDB::Document.new @database, "_id" => "test_document_2", "category" => "two"
    @document_two.save

    @design = CouchDB::Design.new @database, "design_1"
    @view = CouchDB::Design::View.new @design, "view_1",
      "function(document) { emit([ document['category'], document['_id'] ]); }"
    @design.save
  end

  describe "collection" do

    it "should return a collection including the right rows" do
      collection = @view.collection :startkey => [ "one", nil ], :endkey => [ "one", { } ]
      collection.size.should == 1
      collection[0].id.should == "test_document_1"
      collection[0].key.should == [ "one", "test_document_1" ]
      collection[0].value.should be_nil
    end

    it "should return a collection including the right documents" do
      collection = @view.collection :startkey => [ "one", nil ], :endkey => [ "one", { } ]
      collection.documents.should include(@document_one)
      collection.documents.should_not include(@document_two)
    end

  end

  describe "all documents collection" do

    it "should return a collection with all documents of the database" do
      collection = @database.documents
      collection.size.should == 3 # two documents plus the design
    end

  end

end
