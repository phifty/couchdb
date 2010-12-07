
module CouchDB

  # See CouchDB::Design class for description.
  class Design < Document

    # The View class acts as a wrapper for the views that are in the CouchDB design document. It also
    # provides methods to generate simple view javascript functions.
    class View

      attr_accessor :design
      attr_accessor :name
      attr_accessor :map
      attr_accessor :reduce

      def initialize(design, name, map = nil, reduce = nil)
        @design, @name, @map, @reduce = design, name, map, reduce
        @design.views << self
      end

      def to_hash
        { @name => { "map" => @map, "reduce" => @reduce } }
      end

      def collection(options = { })
        @design ? Collection.new(@design.database, url, options) : nil
      end

      def url
        @design ? "#{@design.url}/_view/#{@name}" : nil
      end

    end

  end

end
