
module CouchDB

  # Collection is a proxy class for the result-set of a CouchDB view. It provides
  # all read-only methods of an array. The loading of content is lazy and
  # will be triggered on the first request.
  class Collection

    REQUEST_PARAMETER_KEYS = [
      :key, :startkey, :startkey_docid, :endkey, :endkey_docid,
      :limit, :stale, :descending, :skip, :group, :group_level,
      :reduce, :inclusive_end, :include_docs
    ].freeze unless defined?(REQUEST_PARAMETER_KEYS)

    ARRAY_METHOD_NAMES = [
      :[], :at, :collect, :compact, :count, :cycle, :each, :each_index,
      :empty?, :fetch, :index, :first, :flatten, :include?, :join, :last,
      :length, :map, :pack, :reject, :reverse, :reverse_each, :rindex,
      :sample, :shuffle, :size, :slice, :sort, :take, :to_a, :to_ary,
      :values_at, :zip
    ].freeze unless defined?(ARRAY_METHOD_NAMES)

    attr_reader :database
    attr_reader :url
    attr_reader :options
    attr_reader :documents

    def initialize(database, url, options = { })
      @database, @url, @options = database, url, options
      @documents = DocumentsProxy.new self
    end

    def total_count
      fetch_meta unless @total_count
      @total_count
    end

    def respond_to?(method_name)
      ARRAY_METHOD_NAMES.include?(method_name) || super
    end

    def method_missing(method_name, *arguments, &block)
      if ARRAY_METHOD_NAMES.include?(method_name)
        fetch
        @entries.send method_name, *arguments, &block
      else
        super
      end
    end

    private

    def fetch
      fetch_response
      evaluate_total_count
      evaluate_entries
      true
    end

    def fetch_meta
      fetch_meta_response
      evaluate_total_count
      true
    end

    def fetch_response
      @response = Transport::JSON.request(
        :get, url,
        :parameters => request_parameters,
        :expected_status_code => 200,
        :encode_parameters => true
      )
    end

    def fetch_meta_response
      @response = Transport::JSON.request(
        :get, url,
        :parameters => request_parameters.merge(:limit => 0),
        :expected_status_code => 200,
        :encode_parameters => true
      )
    end

    def request_parameters
      parameters = { }
      REQUEST_PARAMETER_KEYS.each do |key|
        parameters[key] = @options[key] if @options.has_key?(key)
      end
      parameters
    end

    def evaluate_total_count
      @total_count = @response["total_rows"]
    end

    def evaluate_entries
      @entries = (@response["rows"] || [ ]).map{ |row_hash| Row.new @database, row_hash }
    end

    # A proxy class for the collection's fetched documents.
    class DocumentsProxy

      def initialize(collection)
        @collection = collection
      end

      def method_missing(method_name, *arguments, &block)
        if ARRAY_METHOD_NAMES.include?(method_name)
          @collection.options[:include_docs] = true
          @documents = @collection.map{ |row| row.document }
          @documents.send method_name, *arguments, &block
        else
          super
        end
      end

    end

  end

end
