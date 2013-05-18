require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'helper'))

describe CouchDB::Server do

  before :each do
    @server = mock_test_server
  end

  describe '#information' do

    it 'should request server information' do
      @server.information.should == { 'couchdb' => 'Welcome', 'version' => '1.2.0' }
    end

  end

  describe '#statistics' do

    it 'should request server statistics' do
      @server.statistics.should == { 'couchdb' => { } }
    end

  end

  describe '#database_names' do

    it 'should request the names of all databases' do
      @server.database_names.should == %w{test}
    end

  end

  describe '#uuids' do

    it 'should request a given number of uuids' do
      @server.uuids(3).should == [ 1, 2, 3 ]
    end

  end

end
