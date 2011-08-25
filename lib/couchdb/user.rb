require 'digest/sha1'

# Abstracts a CouchDB user.
class CouchDB::User

  attr_reader :user_database

  attr_accessor :document

  def initialize(user_database)
    @user_database = user_database
    @document = CouchDB::Document.new @user_database.database
    @document["type"] = "user"
    @document["salt"] = @user_database.server.password_salt
  end

  def id=(value)
    @document["_id"] = value
  end

  def id
    @document["_id"]
  end

  def name=(value)
    @document["name"] = value
    self.id = "org.couchdb.user:#{value}"
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
    @document.save
  rescue Transport::UnexpectedStatusCodeError => error
    raise error unless error.status_code == 409
    old_document = @document
    load
    @document["name"], @document["password_sha"], @document["roles"] = old_document.values_at "name", "password_sha", "roles"
    retry
  end

  def destroy
    @document.destroy
  end

end
