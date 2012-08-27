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
  
end
