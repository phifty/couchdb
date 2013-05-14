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
