require 'digest/sha1'

# Abstracts a CouchDB user.
class CouchDB::User

  attr_reader :user_database

  attr_accessor :document

  def initialize(user_database, name)
    @user_database = user_database

    @document = CouchDB::Document.new @user_database.database
    @document["_id"] = "org.couchdb.user:#{name}"
    @document["type"] = "user"
    @document["name"] = name
    @document["salt"] = @user_database.server.password_salt
    @document["roles"] = [ ]
  end

  def id
    @document["_id"]
  end

  def name
    @document["name"]
  end

  def password=(value)
    @document["password_sha"] = Digest::SHA1.hexdigest value
  end

  def password
    @document["password_sha"]
  end

  def roles=(value)
    @document["roles"] = value || [ ]
  end

  def roles
    @document["roles"]
  end

  def ==(other)
    @document == other.document
  end

  def load
    @document.load
  end

  def save
    document = CouchDB::Document.new @user_database.database
    document.id = self.id
    document.fetch_rev
    @document["_rev"] = document.rev if document.rev
    @document.save
  end

  def destroy
    @document.destroy
  end

end
