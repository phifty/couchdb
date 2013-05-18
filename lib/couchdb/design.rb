
# The Design class acts as a wrapper for CouchDB design documents.
class CouchDB::Design < CouchDB::Document

  autoload :View, File.join(File.dirname(__FILE__), 'design', 'view')

  attr_accessor :language
  attr_reader :views

  def initialize(database, id, language = 'javascript')
    super database
    self.id, self.language = id, language
    @views = ViewsProxy.new self
  end

  def id
    id = super
    id ? id.sub(/^_design\//, '') : nil
  end

  def id=(value)
    super((value =~ /^_design\//) ? value : "_design/#{value}")
  end

  def language
    self['language']
  end

  def language=(value)
    self['language'] = value
  end

  def url
    "#{self.database.url}/_design/#{self.id}"
  end

  private

  # A proxy class for the views property.
  class ViewsProxy

    def initialize(design)
      @design = design
      @design['views'] = { }
    end

    def <<(view)
      @design['views'].merge! view.to_hash
    end

    def [](name)
      name = name.to_s
      views = @design['views']
      return nil unless views.has_key?(name)
      map, reduce = views[name].values_at('map', 'reduce')
      CouchDB::Design::View.new @design, name, map, reduce
    end

  end

end
