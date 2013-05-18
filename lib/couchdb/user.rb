require 'digest/sha1'
require 'securerandom'

# Abstracts a CouchDB user.
class CouchDB::User

  def initialize(database, document = { :type => 'user', :roles => [ ] })
    @database, @document = database, document
  end

  def id
    @document['_id']
  end

  def name=(value)
    @document['_id'] = "org.couchdb.user:#{value}"
    @document['name'] = value
  end

  def name
    @document['name']
  end

  def password=(value)
    @document['salt'] = SecureRandom.base64 20
    @document['password_sha'] = Digest::SHA1.hexdigest(value + @document['salt'])
  end

  def password
    @document['password_sha']
  end

  def roles=(value)
    @document['roles'] = value || [ ]
  end

  def roles
    @document['roles']
  end

  def save
    @database.documents.update @document
  end

end
