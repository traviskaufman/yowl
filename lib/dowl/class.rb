module DOWL
  
  class Class < DOWL::LabelledDocObject
    include Comparable
    
    attr_reader :resource
    
    def initialize(resource, schema)
      super(resource, schema)
    end
    
    def sub_class_of()
      parent = @schema.model.first_value( 
        RDF::Query::Pattern.new(@resource, DOWL::Namespaces::RDFS.subClassOf)
      )
      if parent
        uri = parent.to_s
        if @schema.classes[uri]
          return @schema.classes[uri]
        else
          return uri
        end
      end
      return nil
    end
   
    def see_alsos()
       links = []
       @schema.model.query( 
         RDF::Query::Pattern.new(@resource, DOWL::Namespaces::RDFS.seeAlso)
       ) do |statement|
         links << statement.object.to_s
       end
       return links
    end
    
    def super_classes()
      list = []
    
      @schema.model.query(
        RDF::Query::Pattern.new(@resource, DOWL::Namespaces::RDFS.subClassOf)
      ) do |statement|
        if statement.object.uri?
          list << DOWL::Class.new(statement.object, @schema)
        else
          puts "WARNING: Found rdfs:subClassOf triple without a valid subject: #{statement.object.inspect}"
        end
      end
      return list
    end    

    def hasSuperClasses?
      return ! super_classes.empty?()
    end
    
    def hasSuperClassesInSchema?
      super_classes.each() do |klass|
        if @schema.classes[klass.uri]
          return true
        end
      end
      return false
    end
    
    def sub_classes()
      list = []
        
      @schema.model.query(
        RDF::Query::Pattern.new(nil, DOWL::Namespaces::RDFS.subClassOf, @resource)
      ) do |statement|
        list << DOWL::Class.new(statement.subject, @schema)
      end
      return list
    end
    
    def hasSubClasses?
      return ! sub_classes.empty?()
    end
    
  end
  
  
end