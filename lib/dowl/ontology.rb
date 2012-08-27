require 'dowl'

module DOWL

  class Ontology < DOWL::LabelledDocObject
   
    def initialize(resource, schema)
        super(resource, schema)  
    end
    
    def ns()
      uri = uri()
      lastChar = uri[-1,1] 
      return (lastChar == '/' or lastChar == '#') ? uri : uri + '#'
    end
    
    def resourceNameHtml
      
      return "#{@schema.name}.html"
    end
    
    def resourceNameSvg
      
      return "#{@schema.name}.svg"
    end
    
    def title()
      dctermsTitle = get_literal(DOWL::Namespaces::DCTERMS.title)
      if dctermsTitle
        return dctermsTitle
      end 
      dcTitle = get_literal(DOWL::Namespaces::DC.title)
      if dcTitle
        return dcTitle
      end
      return short_name() # We have to have a title
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
        uri = statement.object
        if (uri and uri.uri?)
          authors << Person.new(uri, @schema)
        end
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
    
    def hasAuthors?
      return ! authors.empty?
    end
    
    def numberOfClasses()
      return @schema.classes.size()
    end
    
    def numberOfProperties()
      return @schema.properties.size()
    end
    
    def imports()
      imports = []
      @schema.model.query( 
        RDF::Query::Pattern.new(@resource, DOWL::Namespaces::OWL.imports)
      ) do |statement|
        imports << Import.new(statement.object, @schema)
      end
      return imports
    end
    
  end

end
