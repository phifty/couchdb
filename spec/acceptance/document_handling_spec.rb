require File.join(File.dirname(__FILE__), '..', 'helper')

describe 'document handling' do

  before :each do
    @server = make_test_server
    @database = make_test_database @server
    @database.delete_if_exists!
    @database.create_if_missing!

    @document = {
      :_id => 'test_document_1',
      :test => 'test value'
    }
    @database.documents.update @document
  end

  after :each do
    begin
      @database.documents.destroy @document
    rescue CouchDB::DocumentNotFound
      # ignore
    end
  end

  describe 'fetching' do

    it 'should load the document' do
      @document[:test] = nil
      @document = @database.documents.fetch @document
      @document[:test].should == 'test value'
    end

    it 'should raise an error if document not found' do
      lambda do
        @database.documents.fetch :_id => 'invalid'
      end.should raise_error(CouchDB::DocumentNotFound)
    end

  end

  describe 'creating' do

    before :each do
      begin
        @database.documents.destroy @document
      rescue CouchDB::DocumentNotFound
        # ignore
      end
    end

    it 'should create the document' do
      @database.documents.create @document
      @database.documents.fetch(@document).should_not be_nil
    end

  end

  describe 'updating' do

    it 'should update the document' do
      revision = @document[:_rev]
      @document[:test] = 'another test value'
      @database.documents.update @document
      @document[:_rev].should_not == revision
    end

  end

  describe 'destroying' do

    it 'should destroy the document' do
      @database.documents.destroy @document
      lambda do
        @database.documents.fetch(@document).should be_nil
      end.should raise_error(CouchDB::DocumentNotFound)
    end

    it 'should raise an error if document not found' do
      lambda do
        @database.documents.destroy :_id => 'invalid'
      end.should raise_error(CouchDB::DocumentNotFound)
    end

  end

end
