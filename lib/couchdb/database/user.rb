
# Wraps all methods for the user database.
class CouchDB::Database::User

  def initialize(server)
    @database = CouchDB::Database.new server, '_users'
  end

  def users
    documents.all.map do |row|
      if row.id =~ /^org\.couchdb\.user:.+$/
        CouchDB::User.new @database, row['document']
      else
        nil
      end
    end.compact
  end

  def documents
    @database.documents
  end

end
