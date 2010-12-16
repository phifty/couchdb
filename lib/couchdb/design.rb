
module CouchDB

  # The Design class acts as a wrapper for CouchDB design documents.
  class Design < Document

    autoload :View, File.join(File.dirname(__FILE__), "design", "view")

    attr_accessor :language
    attr_reader :views

    def initialize(database, id, language = "javascript")
      super database
      self.id, self.language = id, language
      @views = ViewsProxy.new self
    end

    def id
      super.sub /^_design\//, ""
    end

    def id=(value)
      super "_design/#{value}"
    end

    def language
      self["language"]
    end

    def language=(value)
      self["language"] = value
    end

    private

    # A proxy class for the views property.
    class ViewsProxy

      def initialize(design)
        @design = design
        @design["views"] = { }
      end

      def <<(view)
        @design["views"].merge! view.to_hash
      end

      def [](name)
        name = name.to_s
        views = @design["views"]
        return nil unless views.has_key?(name)
        map, reduce = views[name].values_at("map", "reduce")
        Design::View.new @design, name, map, reduce
      end

    end

  end

end
