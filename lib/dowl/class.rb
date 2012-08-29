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
        #
        # Only look at statements like these:
        #
        # <rdfs:subClassOf rdf:resource="<uri>"/>
        #
        # And ignore statements like these:
        #
        # <rdfs:subClassOf>
        #   <owl:Restriction>
        #     <owl:onProperty rdf:resource="<uri>"/>
        #     <owl:allValuesFrom rdf:resource="<uri>"/>
        #   </owl:Restriction>
        # </rdfs:subClassOf>
        #
        if statement.object.uri?
          list << DOWL::Class.new(statement.object, @schema)
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
      return list.sort { |x,y| x <=> y }  
    end
    
    def hasSubClasses?
      return ! sub_classes.empty?()
    end
    
    def associations()
      list = []
        
      query = RDF::Query.new do
        pattern [:property, DOWL::Namespaces::RDFS.domain, @resource]
        pattern [:property, DOWL::Namespaces::RDFS.range, :range]
      end
    
      query.execute(graph).each do |statement|
        range = statement.object
        puts "Found Association from #{short_name} to #{range}"
        rangeClass = @schema.classes[range]
        puts " - Found this class for it: #{rangeClass}"
        if rangeClass
          list << DOWL::Association.new(self, rangeClass, statement.subject)
        end
      end

      return list
    end
    
  end
  
  class Association 
    
    attr_reader :domainClass
    attr_reader :rangeClass
    attr_reader :property
    
    def initialize(domainClass, rangeClass, property)
      @domainClass = domainClass
      @rangeClass = rangeClass
      @property = property
    end
    
    def label
      return @property.to_s
    end
  
end