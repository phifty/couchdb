require 'faraday'
require 'json'

# The Server class provides methods to retrieve information and statistics
# of a CouchDB server.
class CouchDB::Server

  attr_reader :connection

  def initialize(host = nil, port = nil, username = nil, password = nil)
    @connection = Faraday.new :url => "http://#{host || 'localhost'}:#{port || 5984}" do |builder|
      builder.request :basic_auth, username, password if username && password
      if block_given?
        yield builder
      else
        builder.response :logger
        builder.adapter Faraday.default_adapter
      end
    end
  end

  def path
    ''
  end

  def request_json(method, path, data = nil)
    response = @connection.send method, path, data ? JSON.dump(data) : nil do |request|
      request.headers['Content-Type'] = 'application/json'
      request.headers['Accept'] = 'application/json'
    end
    JSON.parse response.body, :symbolize_names => true
  rescue JSON::ParserError => error
    p error
  end

  def information
    request_json :get, '/'
  end

  def statistics
    p request_json :get, '/_stats'
  end

  def database_names
    request_json :get, '/_all_dbs'
  end

  def uuids(count = 1)
    request_json(:get, '/_uuids', :count => count)['uuids']
  end

  def user_database
    @user_database ||= CouchDB::Database::User.new self
  end

end
