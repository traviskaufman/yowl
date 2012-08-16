require 'rexml/document'

module DOWL
  
  #Utility class providing access to information about the schema, e.g. its description, lists of classes, etc
  class Schema
    
    attr_reader :model
    attr_reader :introduction
    attr_reader :datatype_properties
    attr_reader :object_properties
    attr_reader :classes
    attr_reader :prefixes
    attr_reader :dir
    attr_reader :ontology
    
    def initialize(model, prefixes)
      @model = model
      @prefixes = prefixes
      init()
    end
    
    #
    # Read the prefixes from the XML file using REXML
    #
    private
    def Schema.read_prefixes(ontology_file_name)
      prefixes = {}
      xmldoc = REXML::Document.new(IO.read(ontology_file_name))
      xmldoc.doctype.entities.each() do |prefix, entity|
        namespace = entity.normalized()
        if namespace.include?('://')
          prefixes[prefix] = namespace
        end
      end
      
      return prefixes
    end
    
    def Schema.create_from_file(file=nil)
      if file == nil
        raise "Filename should be provided"
      end
      prefixes = read_prefixes(file)
      model = RDF::Graph.new(file, :prefixes => prefixes)
      model.load!
      
#     @prefixes.each_pair do |prefix, namespace|
#       warn "Prefix " + prefix + " Namespace " + namespace
#     end
      
      return Schema.new(model, prefixes)
    end       
    
    private
    def init()
      
      @classes = Hash.new
      
      init_classes( DOWL::Namespaces::OWL.Class )
      init_classes( DOWL::Namespaces::RDFS.Class )
      
      @datatype_properties = init_properties( DOWL::Namespaces::OWL.DatatypeProperty)      
      @object_properties = init_properties( DOWL::Namespaces::OWL.ObjectProperty)

      ontology = @model.first_subject(RDF::Query::Pattern.new(nil, RDF.type, DOWL::Namespaces::OWL.Ontology))
      if ontology
        @ontology = Ontology.new(ontology, self)
      else
        warn "WARNING: Ontology not found in schema"
      end
    end
    
    private
    def init_classes(type)
      @model.query( RDF::Query::Pattern.new( nil, RDF.type, type ) ) do |statement|
        if !statement.subject.anonymous?
            cls = DOWL::Class.new(statement.subject, self)
            @classes[ statement.subject.to_s ] = cls                    
        end
      end      
    end
    
    private
    def init_properties(type)
      properties = Hash.new
      @model.query( RDF::Query::Pattern.new( nil, RDF.type, type ) ) do |statement|
        properties[ statement.subject.to_s] = DOWL::Property.new(statement.subject, self)
      end      
      return properties      
    end
    
    def properties()
      return @datatype_properties.merge( @object_properties )     
    end
    
    def list_properties()
      return properties().sort { |x,y| x[1] <=> y[1] }          
    end
    
    def list_datatype_properties()
      return datatype_properties().sort { |x,y| x[1] <=> y[1] }
    end
    
    def list_object_properties()
      return object_properties().sort { |x,y| x[1] <=> y[1] }
    end    
    
    #Return sorted, nested array
    def list_classes()
      sorted = classes().sort { |x,y| x[1] <=> y[1] }
      return sorted      
    end
    
    #
    # Replace the namespace in the given uri with the corresponding prefix, if defined
    #
    def prefixedUri(uri)
      @prefixes.each() do |prefix, namespace|
        #
        # Not sure whether still simplistic "algorithm" works in all cases
        #
        if uri.contains(namespace)
          return uri.gsub!(namespace, prefix + ':')
        end
      end
      ontology_uri = @ontology.uri
      uri = uri.gsub(ontology_uri + '#', "")
      uri = uri.gsub(ontology_uri + '/', "")
      return uri.gsub(ontology_uri, "")
    end
  end  
  
end
