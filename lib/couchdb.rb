require 'transport'

module CouchDB

  autoload :Server, File.join(File.dirname(__FILE__), "couchdb", "server")
  autoload :Database, File.join(File.dirname(__FILE__), "couchdb", "database")
  autoload :Document, File.join(File.dirname(__FILE__), "couchdb", "document")
  autoload :Design, File.join(File.dirname(__FILE__), "couchdb", "design")
  autoload :Collection, File.join(File.dirname(__FILE__), "couchdb", "collection")
  autoload :Row, File.join(File.dirname(__FILE__), "couchdb", "row")

end
