
# Abstracts a CouchDB database security document.
class CouchDB::Security

  attr_reader :administrators
  attr_reader :readers

  def initialize(database)
    @database = database

    @document = CouchDB::Document.new @database
    @document.id = '_security'
    @document.fetch_rev
    @document['admins'] = { }
    @document['readers'] = { }

    @administrators = UsersAndRolesProxy.new @document['admins']
    @readers = UsersAndRolesProxy.new @document['readers']
  end

  def load
    @document.load
  end

  def save
    @document.save
  rescue Transport::UnexpectedStatusCodeError => error
    raise error unless error.status_code == 200
  end

  # Proxy to manipulate an array structure of users and roles.
  class UsersAndRolesProxy

    attr_reader :names
    attr_reader :roles

    def initialize(hash)
      @hash = hash
      @names = @hash['names'] = [ ]
      @roles = @hash['roles'] = [ ]
    end

    def clear!
      @names.clear
      @roles.clear
    end

    def <<(user_or_role)
      @names << user_or_role.name if user_or_role.is_a?(CouchDB::User)
      @roles << user_or_role if user_or_role.is_a?(String)
    end

  end

end