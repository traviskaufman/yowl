require 'dowl'

module DOWL

  class Ontology < DOWL::LabelledDocObject
   
    def initialize(resource, schema)
        super(resource, schema)  
    end
    
    def uri() 
        return @resource.to_s
    end
    
    def title()
      return get_literal(DOWL::Namespaces::DCTERMS.title)
    end
    
    def created()
      return get_literal(DOWL::Namespaces::DCTERMS.created)
    end

    def modified()
      return get_literal(DOWL::Namespaces::DCTERMS.modified)
    end
    
    def authors()      
      authors = []
      @schema.model.query( 
        RDF::Query::Pattern.new( @resource, DOWL::Namespaces::FOAF.maker ) ) do |statement|
          authors << Person.new( statement.object, @schema )
      end         
      @schema.model.query( 
        RDF::Query::Pattern.new( @resource, DOWL::Namespaces::DC.creator ) ) do |statement|
          person = Person.new( nil, @schema )
          person.setName(statement.object)
          authors << person
      end         
      return authors.sort     
    end
    
  end
end
