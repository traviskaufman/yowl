module DOWL
  
  class DocObject
    
    attr_reader :resource
    attr_reader :schema
    
    def initialize(resource, schema)
      @resource = resource
      @schema = schema
      puts "*** #{@resource.to_s} ***"
    end  
    
    def uri() 
      return @resource.to_s
    end    

    def short_name()
      return @schema.prefixedUri(uri)
    end
    
    def to_s()
      return short_name()
    end    
    
    def get_literal(property)
      return @schema.model.first_value(RDF::Query::Pattern.new(@resource, property))
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
    
    def hasDifferentLabel()
      return short_name() != label()
    end
        
    def comment()
      return get_literal(DOWL::Namespaces::RDFS.comment)
    end
    
    def hasComment()
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
