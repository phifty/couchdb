
module CouchDB

  # Base is the main super class of all models that should be stored in CouchDB.
  # See the README file for more informations.
  class Document

    # The NotFoundError will be raised if an operation is tried on a document that
    # dosen't exists.
    class NotFoundError < StandardError; end

    attr_reader :database

    def initialize(database, properties = { })
      @database = database
      @properties = properties
    end

    def [](key)
      @properties[key.to_s]
    end

    def []=(key, value)
      @properties[key.to_s] = value
    end

    def id
      self["_id"]
    end

    def id=(value)
      self["_id"] = value
    end

    def rev
      self["_rev"]
    end

    def rev=(value)
      self["_rev"] = value
    end

    def each_property(&block)
      @properties.each &block
    end

    def ==(other)
      self.id == other.id
    end

    def new?
      self.rev.nil?
    end

    def exists?
      Transport::JSON.request :get, url, :expected_status_code => 200
      true
    rescue Transport::UnexpectedStatusCodeError => error
      raise error unless error.status_code == 404
      false
    end

    def load
      @properties = Transport::JSON.request :get, url, :expected_status_code => 200
      true
    rescue Transport::UnexpectedStatusCodeError => error
      upgrade_unexpected_status_error error
    end
    alias reload load

    def save
      new? ? create : update
    end

    def destroy
      return false if new?
      Transport::JSON.request :delete, url, :headers => { "If-Match" => self.rev }, :expected_status_code => 200
      self.rev = nil
      true
    rescue Transport::UnexpectedStatusCodeError => error
      upgrade_unexpected_status_error error
    end

    def url
      "#{self.database.url}/#{self.id}"
    end

    private

    def create
      response = Transport::JSON.request :post, @database.url, :body => @properties, :expected_status_code => 201
      self.id  = response["id"]
      self.rev = response["rev"]
      true
    rescue Transport::UnexpectedStatusCodeError
      false
    end

    def update
      response = Transport::JSON.request :put, url, :body => @properties, :expected_status_code => 201
      self.rev = response["rev"]
      true
    rescue Transport::UnexpectedStatusCodeError
      false
    end

    def upgrade_unexpected_status_error(error)
      raise NotFoundError if error.status_code == 404
      raise error
    end

    def self.create(*arguments)
      model = new *arguments
      model.save ? model : nil
    end

  end

end
