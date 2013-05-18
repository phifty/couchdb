require 'rubygems'
gem 'rspec', '>= 2'
require 'rspec'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'couchdb'))

def make_test_server
  CouchDB::Server.new 'localhost', 5984, 'test', 'test'
end

def make_test_database(server)
  CouchDB::Database.new server, 'test'
end

def mock_test_server
  CouchDB::Server.new 'host', 1234, 'test', 'test' do |builder|
    builder.adapter :test do |stubs|
      stubs.get('/') { [ 200, { }, '{ "couchdb": "Welcome", "version": "1.2.0" }' ] }
      stubs.get('/_stats') { [ 200, { }, '{ "couchdb": { } }' ] }
      stubs.get('/_all_dbs') { [ 200, { }, %w{test} ] }
      stubs.get('/_uuids?count=3') { [ 200, { }, { 'uuids' => [ 1, 2, 3 ] } ] }

      stubs.get('/test') { [ 200, { }, 'database_information' ] }
      stubs.put('/test') { [ 201, { }, 'database_created' ] }
      stubs.delete('/test') { [ 200, { }, 'database_deleted' ] }
      stubs.post('/test/_compact') { [ 200, { }, 'database_compacted' ] }
    end
  end
end
