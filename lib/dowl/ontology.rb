module DOWL

  class Ontology < DOWL::LabelledDocObject
    
    def initialize(resource, schema)
      super(resource, schema)  
    end
    
    def resourceNameHtml
      return "#{@schema.name}.html"
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
    
    def ns()
      @ns ||= init_ns()
      return @ns
    end
    
    def init_ns()
      _uri = @resource.to_s
      @schema.prefixes.each do |prefix, namespace|
        if _uri == namespace
          return namespace
        end
        _tmp = "#{_uri}/"
        if _tmp == namespace
          return _tmp
        end
        _tmp = "#{_uri}#"
        if "#{_uri}#" == namespace
          return _tmp
        end
      end
      if _uri[-1..1] == '/' or _uri[-1..1] == '#'
        return _uri
      end
      #
      # Basically make up a namespace... Don't know if this is such a good plan..
      #
      return "#{_uri}#"
    end
    
    def short_name()
      return @schema.name
    end
    
    def comment()
      dctermsAbstract = get_literal(DOWL::Namespaces::DCTERMS.abstract)
      if dctermsAbstract
        return dctermsAbstract
      end
      return super
    end
    
    def definition()
      return get_literal(DOWL::Namespaces::SKOS.definition)
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
    
    public
    def authors
      @authors ||= init_authors
    end
    
    private
    def init_authors()      
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
        person = Person.new(RDF::URI.new("#{ns}#{statement.object.to_s}"), @schema)
        person.setName(statement.object)
        authors << person
      end         
      @schema.model.query( 
        RDF::Query::Pattern.new(@resource, DOWL::Namespaces::DC.contributor)
      ) do |statement|
        person = Person.new(RDF::URI.new("#{ns}#{statement.object.to_s}"), @schema)
        person.setName(statement.object)
        authors << person
      end 
      return authors        
    end
    
    public
    def hasAuthors?
      return ! authors.empty?
    end
    
    def numberOfClasses()
      return @schema.classes.size()
    end
    
    def numberOfProperties()
      return @schema.properties.size()
    end
    
    def numberOfIndividuals()
      return @schema.individuals.size()
    end
    
    public
    def imports
      @imports ||= init_imports
    end
    
    private
    def init_imports
      imports = {}
      @schema.model.query( 
        RDF::Query::Pattern.new(@resource, DOWL::Namespaces::OWL.imports)
      ) do |statement|
        importUri = statement.object.to_s
        if importUri != uri
          imports[importUri] = Import.new(statement.object, @schema)
        end
      end
      return imports.values
    end
    
    public
    def see_alsos
      @see_alsos ||= init_see_alsos
    end
    
    private
    def init_see_alsos()
       links = []
       @schema.model.query(
         RDF::Query::Pattern.new(@resource, DOWL::Namespaces::RDFS.seeAlso)
       ) do |statement|
         links << statement.object.to_s
       end       
       return links
    end
    
    public
    #
    # See DOWL::Individual::classWithURI(uri)
    #
    def classWithURI(uri_)
      klass = @schema.classInSchemaWithURI(uri_)
      if klass
        return klass
      end
      imports.each do |import|
        klass = import.classWithURI(uri_)
        if klass
          return klass
        end
      end
      return nil
    end
    
  end

end
