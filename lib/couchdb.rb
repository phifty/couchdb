require 'transport'

module CouchDB

  autoload :Collection, File.join(File.dirname(__FILE__), 'couchdb', 'collection')
  autoload :Database, File.join(File.dirname(__FILE__), 'couchdb', 'database')
  autoload :Design, File.join(File.dirname(__FILE__), 'couchdb', 'design')
  autoload :Document, File.join(File.dirname(__FILE__), 'couchdb', 'document')
  autoload :Row, File.join(File.dirname(__FILE__), 'couchdb', 'row')
  autoload :Server, File.join(File.dirname(__FILE__), 'couchdb', 'server')
  autoload :User, File.join(File.dirname(__FILE__), 'couchdb', 'user')
  autoload :UserDatabase, File.join(File.dirname(__FILE__), 'couchdb', 'user_database')

  class DocumentNotFound < StandardError; end

end
