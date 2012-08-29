module DOWL
  
  class DocObject
    
    attr_reader :resource
    attr_reader :schema
    
    def initialize(resource, schema)
      @resource = resource
      @schema = schema
      if (@resource and not @resource.uri?)
        raise "ERROR: Instantiating an object with a non-URI resource: #{@resource.inspect}"
      end
    end  
    
    def uri 
      return @resource ? @resource.to_s : nil
    end
    
    def hasUri?
      return @resource ? true : false
    end    

    def short_name()
      str = @schema.prefixedUri(uri)
      if (str.nil? or str.empty?())
        return uri
      end
      return str
    end

    def escaped_short_name()
      str = short_name()
      str = str.gsub("://", "_")
      str = str.gsub(".", "_")
      str = str.gsub("/", "_")
      return str
    end
    
    def escaped_uri()
      str = uri.to_s
      str = str.gsub("://", "__")
      str = str.gsub(".", "_")
      str = str.gsub("/", "_")
      return str
    end
    
    def to_s()
      return short_name()
    end    
    
    def get_literal(property)
      return hasUri? ? @schema.model.first_value(RDF::Query::Pattern.new(@resource, property)) : nil
    end
    
  end
  
  class LabelledDocObject < DOWL::DocObject
    
    def initialize(resource, schema)
       super(resource, schema)
    end
    
    def label()
      label = get_literal(DOWL::Namespaces::RDFS.label)
      return label.nil? ? short_name() : label
    end
    
    def hasDifferentLabel?
      return short_name().sub(/.+:/, '') != label()
    end
        
    def comment()
      return get_literal(DOWL::Namespaces::RDFS.comment)
    end
    
    def hasComment?
      comment = comment()
      return (comment and not comment.empty?)
    end
    
    def status()      
      return get_literal(DOWL::Namespaces::VS.status)
    end

    def <=>(other)
      return label().downcase <=> other.label().downcase
    end    
    
  end
  
  class GraphvizUtility
  
  	def GraphvizUtility.setDefaults(g)
  	  
      g[:rankdir] = "BT"
        
      g.node[:peripheries] = 0
      g.node[:style] = "rounded,filled"
      g.node[:fillcolor] = "#0861DD" 
      g.node[:fontcolor] = "white"
      g.node[:fontname] = "Verdana" 
      g.node[:shape] = "box"
      g.node[:fontsize] = 10
      g.node[:fixedsize] = true
      g.node[:width] = 1.3
      g.node[:height] = 0.6
        
      g.edge[:fontname] = "Verdana"
      g.edge[:fontsize] = 8
      g.edge[:fontcolor] = "#0861DD"
      g.edge[:labeldistance] = 2
        
      return g
  	end
  	
  	def GraphvizUtility.embeddableSvg(g)
  	  warn "Generated Dot is:\n#{g.to_dot}"
  	  svg = g.output(:svg => String)
      index = svg.index("<svg")
      return index ? svg[index..-1] : svg
    end
  end
  
end
