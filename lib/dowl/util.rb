module DOWL
  
  class DocObject
    attr_reader :resource
    attr_reader :schema  
    def initialize(resource, schema)
      @resource = resource
      @schema = schema
    end  
    
    def uri() 
        return @resource.to_s
    end    
    
    def get_literal(property)
      return @schema.model.first_value(RDF::Query::Pattern.new( @resource, property ) )
    end
    
  end
  
  class LabelledDocObject < DOWL::DocObject
    
    def initialize(resource, schema)
       super(resource, schema)
    end
     
    def short_name()
      return @schema.prefixedUri(@resource.to_s)
    end
     
    def label()
      label = get_literal(DOWL::Namespaces::RDFS.label)
      if label == nil
        return short_name()
      end
      return label
    end
    
    def hasDifferentLabel()
      return short_name() != label()
    end
        
    def comment()
      return get_literal(DOWL::Namespaces::RDFS.comment)
    end
    
    def hasComment()
      comment = comment()
      return comment != nil and ! comment.empty?
    end
    
    def status()      
      return get_literal(DOWL::Namespaces::VS.status)
    end
         
    def <=>(other)
      return label().downcase <=> other.label().downcase
    end    
    
  end
  
end
