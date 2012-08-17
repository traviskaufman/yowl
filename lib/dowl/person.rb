module DOWL
  
  class Person < DOWL::DocObject
    @name = nil
    
    def initialize(resource, schema)
      super(resource, schema)
    end
     
    def uri()
      return @resource.to_s
    end

    def setName(name_)
      @name = name_
    end
     
    def name()
      name = get_literal(DOWL::Namespaces::FOAF.name)
      if name == nil
        name = uri()
      end
      return name
    end
     
    def <=>(other)
      return name() <=> other.name()
    end
  end
end