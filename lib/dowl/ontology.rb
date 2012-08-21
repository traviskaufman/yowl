require 'dowl'

module DOWL

  class Ontology < DOWL::LabelledDocObject
   
    def initialize(resource, schema)
        super(resource, schema)  
    end
    
    def title()
      dctermsTitle = get_literal(DOWL::Namespaces::DCTERMS.title)
      if dctermsTitle
        return dctermsTitle
      end 
      return get_literal(DOWL::Namespaces::DC.title)
    end
    
    def comment()
      dctermsAbstract = get_literal(DOWL::Namespaces::DCTERMS.abstract)
      if dctermsAbstract
        return dctermsAbstract
      end
      return super
    end
    
    def created()
      dctermsCreated = get_literal(DOWL::Namespaces::DCTERMS.created)
      if dctermsCreated
        return dctermsCreated
      end
      return get_literal(DOWL::Namespaces::DC.date)
    end

    def modified()
      return get_literal(DOWL::Namespaces::DCTERMS.modified)
    end
    
    def rights()
      return get_literal(DOWL::Namespaces::DC.rights)
    end
    
    def authors()      
      authors = []
      #
      # First find the Authors by searching for foaf:maker
      #
      @schema.model.query( 
        RDF::Query::Pattern.new(@resource, DOWL::Namespaces::FOAF.maker)
      ) do |statement|
        authors << Person.new(statement.object, @schema)
      end
      #
      # Also scan for dc:creator and dc:contributor
      #         
      @schema.model.query( 
        RDF::Query::Pattern.new(@resource, DOWL::Namespaces::DC.creator)
      ) do |statement|
          person = Person.new( nil, @schema )
          person.setName(statement.object)
          authors << person
      end         
      @schema.model.query( 
        RDF::Query::Pattern.new(@resource, DOWL::Namespaces::DC.contributor)
      ) do |statement|
          person = Person.new( nil, @schema )
          person.setName(statement.object)
          authors << person
      end         
      return authors.sort     
    end
    
    def hasAuthors()
      return authors.empty?
    end
    
  end
end
