module DOWL
  
  class Person < DOWL::LabelledDocObject
    
    def initialize(resource, schema)
      super(resource, schema)
      @name = nil
    end
     
    def setName(name_)
      @name = name_
    end
     
    def name()
      name = get_literal(DOWL::Namespaces::FOAF.name)
      if name.nil? or name.empty?
        name = short_name()
      end
      return name
    end
     
    def <=>(other)
      return name() <=> other.name()
    end
  end
end