
module CouchDB

  # The Server class provides methods to retrieve information and statistics
  # of a CouchDB server.
  class Server

    attr_accessor :host
    attr_accessor :port
    attr_accessor :username
    attr_accessor :password

    attr_accessor :password_salt

    def initialize(host = "localhost", port = 5984, username = nil, password = nil)
      @host, @port, @username, @password = host, port, username, password
    end

    def ==(other)
      other.is_a?(self.class) && @host == other.host && @port == other.port
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
      "http://#{@host}:#{@port}"
    end

    def authentication_options
      @username && @password ? { :auth_type => :basic, :username => @username, :password => @password } : { }
    end

    private

    def options
      authentication_options.merge :expected_status_code => 200
    end

  end

end
