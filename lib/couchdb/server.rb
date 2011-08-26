
module CouchDB

  # The Server class provides methods to retrieve information and statistics
  # of a CouchDB server.
  class Server

    attr_writer :host
    attr_writer :port
    attr_accessor :username
    attr_accessor :password

    attr_accessor :password_salt

    def initialize(host = nil, port = nil, username = nil, password = nil)
      @host, @port, @username, @password = host, port, username, password
    end

    def host
      @host || "localhost"
    end

    def port
      @port || 5984
    end

    def ==(other)
      other.is_a?(self.class) && self.host == other.host && self.port == other.port
    end

    def information
      Transport::JSON.request :get, url + "/", options
    end

    def statistics
      Transport::JSON.request :get, url + "/_stats", options
    end

    def database_names
      Transport::JSON.request :get, url + "/_all_dbs", options
    end

    def uuids(count = 1)
      response = Transport::JSON.request :get, url + "/_uuids", options.merge(:parameters => { :count => count })
      response["uuids"]
    end

    def user_database
      @user_database ||= UserDatabase.new self
    end

    def url
      "http://#{self.host}:#{self.port}"
    end

    def authentication_options
      self.username && self.password ? { :auth_type => :basic, :username => self.username, :password => self.password } : { }
    end

    private

    def options
      authentication_options.merge :expected_status_code => 200
    end

  end

end
