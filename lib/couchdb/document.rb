
module CouchDB

  # Base is the main super class of all models that should be stored in CouchDB.
  # See the README file for more information.
  class Document

    autoload :Security, File.join(File.dirname(__FILE__), 'document', 'security')

    # The NotFoundError will be raised if an operation is tried on a document that
    # doesn't exists.
    class NotFoundError < StandardError; end

    # The UnauthorizedError will be raised if the authentication has failed.
    class UnauthorizedError < StandardError; end

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
      self['_id']
    end

    def id=(value)
      self['_id'] = value
    end

    def rev
      self['_rev']
    end

    def rev=(value)
      self['_rev'] = value
    end

    def rev?
      @properties.has_key? '_rev'
    end

    def clear_rev
      @properties.delete '_rev'
    end

    def fetch_rev
      properties = Transport::JSON.request :get, url, authentication_options.merge(:expected_status_code => 200)
      self.rev = properties['_rev']
    rescue Transport::UnexpectedStatusCodeError => error
      raise error unless error.status_code == 404
      @properties.delete '_rev'
    end

    def ==(other)
      self.id == other.id
    end

    def new?
      !self.rev?
    end

    def exists?
      Transport::JSON.request :get, url, authentication_options.merge(:expected_status_code => 200)
      true
    rescue Transport::UnexpectedStatusCodeError => error
      raise error unless error.status_code == 404
      false
    end

    def load
      @properties = Transport::JSON.request :get, url, authentication_options.merge(:expected_status_code => 200)
      true
    rescue Transport::UnexpectedStatusCodeError => error
      upgrade_status_error error
    end
    alias reload load

    def save
      new? ? create : update
    end

    def destroy
      return false if new?
      Transport::JSON.request :delete, url, authentication_options.merge(:headers => { 'If-Match' => self.rev }, :expected_status_code => 200)
      self.clear_rev
      true
    rescue Transport::UnexpectedStatusCodeError => error
      upgrade_status_error error
    end

    def url
      "#{self.database.url}/#{self.id}"
    end

    private

    def create
      response = Transport::JSON.request :post, @database.url, authentication_options.merge(:body => @properties, :expected_status_code => 201)
      self.id  = response['id']
      self.rev = response['rev']
      true
    rescue Transport::UnexpectedStatusCodeError => error
      upgrade_status_error error
      false
    end

    def update
      response = Transport::JSON.request :put, url, authentication_options.merge(:body => @properties, :expected_status_code => 201)
      self.rev = response['rev']
      true
    rescue Transport::UnexpectedStatusCodeError => error
      upgrade_status_error error
      false
    end

    def upgrade_status_error(error)
      raise UnauthorizedError if error.status_code == 401
      raise NotFoundError if error.status_code == 404
      raise error
    end

    def authentication_options
      @database.authentication_options
    end

    def method_missing(method_name, *arguments, &block)
      @properties.send method_name, *arguments, &block
    end

    def self.create(*arguments)
      model = new *arguments
      model.save ? model : nil
    end

  end

end
