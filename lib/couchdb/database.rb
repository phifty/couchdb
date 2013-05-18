
# The Database class provides methods create, delete and retrieve informations
# of a CouchDB database.
class CouchDB::Database

  autoload :User, File.join(File.dirname(__FILE__), 'database', 'user')

  attr_reader :documents

  def initialize(server, name)
    @server, @name = server, name
    @documents = DocumentsProxy.new self
  end

  def path
    "#{@server.path}/#{@name}"
  end

  def request_json(*arguments)
    @server.request_json *arguments
  end

  def ==(other)
    other.is_a?(self.class) && @name == other.name && @server == other.server
  end

  def ===(other)
    object_id == other.object_id
  end

  def create!
    request_json :put, path
  end

  def create_if_missing!
    create! unless exists?
  end

  def delete!
    request_json :delete, path
  end

  def delete_if_exists!
    delete! if exists?
  end

  def compact!
    request_json :post, "#{path}/_compact"
  end

  def information
    request_json :get, path
  end

  def exists?
    @server.database_names.include? @name
  end

  def security
    @security ||= CouchDB::Document::Security.new self
  end

  private

  class DocumentsProxy

    def initialize(database)
      @database = database
    end

    def create(document)
      response = @database.request_json :post, @database.path, document
      document[:_id] = response[:id]
      document[:_rev] = response[:rev]
      document
    end

    def update(document)
      response = @database.request_json :put, path(document), document
      document[:_rev] = response[:rev]
      document
    end

    def fetch(id_or_document)
      document = @database.request_json :get, path(id_or_document)
      raise CouchDB::DocumentNotFound if document[:error] == 'not_found'
      document
    end

    def destroy(response)
      response = @database.request_json :delete, path_with_revision(response)
      raise CouchDB::DocumentNotFound if response[:error] == 'not_found'
      response
    end

    def all(options = { })
      CouchDB::Collection.new @database, '_all_docs', options
    end

    private

    def path_with_revision(document)
      "#{path(document)}?rev=#{document[:_rev]}"
    end

    def path(id_or_document)
      id = id_or_document.is_a?(Hash) ? id_or_document[:_id] : id_or_document.to_s
      "#{@database.path}/#{id}"
    end

  end

end
