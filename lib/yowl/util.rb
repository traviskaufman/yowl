module YOWL
  
  class DocObject
    
    attr_reader :resource
    attr_reader :schema
    
    def initialize(resource, schema)
      @resource = resource
      @schema = schema
      if (@resource and not @resource.uri?)
        raise "ERROR: Instantiating an object with a non-URI resource: #{@resource.to_s} (#{@resource.inspect})"
      end
    end  
    
    def repository
      return @schema.repository
    end
    
    def uri 
      return @resource ? @resource.to_s : nil
    end
    
    def hasUri?(uri_)
      case uri
      when String
        return uri == uri_
      end
      return @resource == uri_
    end  
    
    def ns()
      _uri = uri()
      lastChar = _uri[-1,1]
      if  lastChar == '/' or lastChar == '#'
        return _uri
      end
      return _uri[0.._uri.rindex(/[#\/]/)]
    end
    
    def hasOtherNamespace?
      schemaUri = @schema.uri
      case
      when schemaUri == ns
        return false
      when "#{schemaUri}#" == ns
        return false
      when "#{schemaUri}/" == ns
        return false
      end
      return true
    end

    def short_name()
      name = @schema.prefixedUri(uri)
      prefix = name.sub(/:.*/, '')
      #
      # If the short name looks like this then fix it a little:
      #    <prefix>:<prefix>-name -> <prefix>:name
      #
      name = name.sub(/:#{prefix}-/, ':')
      return name
    end

    def escaped_short_name()
      str = short_name()
      # TODO: optimize this into one pattern
      str = str.gsub("://", "_")
      str = str.gsub(".", "_")
      str = str.gsub(",", "_")
      str = str.gsub("/", "_")
      return str
    end
    
    def escaped_uri()
      str = short_name().to_s
      # TODO: optimize this into one pattern
      str = str.gsub("://", "__")
      str = str.gsub(".", "_")
      str = str.gsub("/", "_")
      str = str.gsub("#", "_")
      str = str.gsub(":", "_")
      str = str.gsub(",", "_")
      return str
    end
    
    def to_s()
      return short_name()
    end    
    
    def get_literal(property)
      if @resource.nil?
        return nil
      end
      value = @schema.model.first_value(RDF::Query::Pattern.new(@resource, property))
      if not value
        return nil
      end
      return value.strip
    end
    
    def ontology
      return @schema.ontology ? @schema.ontology : nil
    end
    
  end
  
  class LabelledDocObject < YOWL::DocObject
    
    def initialize(resource, schema)
       super(resource, schema)
    end
    
    def label()
      label = get_literal(YOWL::Namespaces::RDFS.label)
      return label.nil? ? short_name() : label
    end
    
    def hasDifferentLabel?
      #puts "****\n- #{short_name().sub(/.+:/, '')}\n- #{label}\n****"
      #return short_name().sub(/.+:/, '') != label()
      return short_name() != label()
    end
        
    def comment()
      return get_literal(YOWL::Namespaces::RDFS.comment)
    end
    
    def commentOrLabel()
      if hasComment?
        return comment
      end
      return label
    end
    
    def hasComment?
      comment = comment()
      return (comment and not comment.empty?)
    end
    
    def definition()
      return get_literal(YOWL::Namespaces::SKOS.definition)
    end
    
    def hasDefinition?
      definition = definition()
      return (definition and not definition.empty?)
    end

    def editorialNotes()
      notes = []
      @schema.model.query(
        RDF::Query::Pattern.new(@resource, YOWL::Namespaces::SKOS.editorialNote)
      ) do |statement|
        notes << statement.object.to_s
      end
      return notes
    end

    def hasEditorialNotes?
      return editorialNotes.length > 0
    end
    
    def see_alsos()
      links = []
      @schema.model.query(
      RDF::Query::Pattern.new(@resource, YOWL::Namespaces::RDFS.seeAlso)
      ) do |statement|
        links << statement.object.to_s
      end
      return links
    end            
    
    def status()      
      return get_literal(YOWL::Namespaces::VS.status)
    end

    def <=>(other)
      return label().downcase <=> other.label().downcase
    end    
    
  end
  
  class GraphvizUtility
  
    def GraphvizUtility.setDefaults(g)
  	  
      g[:rankdir] = "BT"

      #g.node[:peripheries] = 0
      g.node[:style] = "rounded,filled"
      g.node[:fillcolor] = "#0861DD" 
      g.node[:fontcolor] = "white"
      g.node[:fontname] = "Helvetica" 
      g.node[:shape] = "box"
      g.node[:fontsize] = 8
      g.node[:fixedsize] = false # Classes with long names need wider boxes
      #g.node[:width] = 1
      g.node[:height] = 0.4
        
      g.edge[:fontname] = "Helvetica"
      g.edge[:fontsize] = 7
      g.edge[:fontcolor] = "#0861DD"
      g.edge[:labeldistance] = 1
        
      return g
    end
  	
    def GraphvizUtility.embeddableSvg(graph_, log_ = false)
      if log_
        puts "Generated Dot is:"
        puts graph_.output(:dot => String)
      end

      svg = graph_.output(:svg => String)
      index = svg.index("<svg")
      
      return index ? svg[index..-1] : svg
    end
  end
end
