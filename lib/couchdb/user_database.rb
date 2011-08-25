
# Wraps all methods for the user database.
class CouchDB::UserDatabase

  attr_reader :server
  attr_reader :database

  def initialize(server, name = "_users")
    @server = server
    @database = CouchDB::Database.new @server, name
  end

  def users
    @database.documents.map do |row|
      if row.id =~ /^org\.couchdb\.user:.+$/
        user = CouchDB::User.new self
        user.id = row.id
        user.load
        user
      else
        nil
      end
    end.compact
  end

end
