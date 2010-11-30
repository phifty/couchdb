require File.expand_path(File.join(File.dirname(__FILE__), "..", "document"))

module CouchDB

  # See CouchDB::Design class for description.
  class Design < Document

    # The View class acts as a wrapper for the views that are in the CouchDB design document. It also
    # provides methods to generate simple view javascript functions.
    class View

      attr_reader :design
      attr_reader :name
      attr_accessor :map
      attr_accessor :reduce

      def initialize(design, name, map = nil, reduce = nil)
        @design, @name, @map, @reduce = design, name, map, reduce
      end

      def to_hash
        { @name => { "map" => @map, "reduce" => @reduce } }
      end

      def url
        "#{@design.url}/_view/#{@name}"
      end

    end

  end

end
