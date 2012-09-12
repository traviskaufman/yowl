require 'rexml/document'

module DOWL

  #
  # Utility class providing access to information about the schema, e.g. its description, lists of classes, etc
  #
  class Schema

    @@PredefinedNamespaces = Hash.new
    @@PredefinedNamespaces["http://protege.stanford.edu/plugins/owl/dc/protege-dc.owl"] = "http://purl.org/dc/elements/1.1/"
    
    attr_reader :options
    attr_reader :repository
    attr_reader :model
    attr_reader :prefixes
    attr_reader :name
    attr_reader :introduction
    attr_reader :datatype_properties
    attr_reader :object_properties
    attr_reader :classes
    attr_reader :dir
    attr_reader :ontology
    
    private
    def initialize(repository, model, prefixes)

      @repository = repository
      @options = repository.options
      @model = model
      @prefixes = prefixes

      if options.verbose
        @prefixes.each_pair do |prefix, namespace|
          puts " PREFIX #{prefix}: #{namespace}"
        end
      end

      @classes = Hash.new
      
      init_classes(DOWL::Namespaces::OWL.Class)
      init_classes(DOWL::Namespaces::RDFS.Class)
      
      @datatype_properties = init_properties(DOWL::Namespaces::OWL.DatatypeProperty)      
      @object_properties = init_properties(DOWL::Namespaces::OWL.ObjectProperty)
      
      init_ontology()
      init_name()
    end
    
    public
    def Schema.fromFile(ontology_file_name, repository)
      
      if repository.options.verbose
        puts "Read Schema #{ontology_file_name}"
      end
      prefixes = Schema::read_prefixes(ontology_file_name)
      
      format = RDF::Format.for(ontology_file_name)
      if format.nil?()
        format = RDF::Format.for(:file_extension => "rdf")
      end
      begin
        model = RDF::Graph.load(ontology_file_name, { :format => format.to_sym, :prefixes => prefixes })
      rescue
        warn "ERROR: Error while parsing #{ontology_file_name}"
        return nil
      end
      
      return Schema.new(repository, model, prefixes)
    end

    #
    # Read the prefixes from the XML file using REXML
    #
    private
    def Schema.read_prefixes(ontology_file_name)
      prefixes = {}
      xmldoc = nil
      begin
        xmldoc = REXML::Document.new(IO.read(ontology_file_name))
      rescue REXML::ParseException => bang
        warn "ERROR: Error while parsing prefixes from #{ontology_file_name} (only works for RDF/XML format)"
        return prefixes
      end
      xmldoc.doctype.entities.each() do |prefix, entity|
        namespace = entity.normalized()
        if namespace.include?('://')
          prefixes[prefix.to_sym] = namespace
        end
      end
      
      return prefixes
    end
    
    public
    def uri
      return @ontology.nil? ? nil : @ontology.uri
    end

    private 
    def testIsNamespace?(ns1_, ns2_)
      ns1 = ns1_.chomp('#').chomp('/')
      ns2 = ns2_.chomp('#').chomp('/')
      #puts "testIsNamespace #{ns1} == #{ns2}"
      return ns1 == ns2
    end
    
    #
    # Return the prefix and the corresponding namespace for the given namespace,
    # where various forms of the given namespace are tried, like <ns>, <ns>/ and <ns>#.
    # When no namespace could be found, return two nils.
    public
    def prefixForNamespace(namespace_)
      ns = @@PredefinedNamespaces.include?(namespace_) ? @@PredefinedNamespaces[namespace_] : namespace_
      @prefixes.each() do |prefix, namespace|
        if testIsNamespace?(namespace, ns)
          return prefix, namespace
        end
      end
      return nil, nil
    end
    
    private
    def init_classes(type)
      @model.query(RDF::Query::Pattern.new(nil, RDF.type, type)) do |statement|
        Class.withUri(statement.subject, self)                    
      end      
    end
    
    private
    def init_properties(type)
      properties = Hash.new
      @model.query(RDF::Query::Pattern.new(nil, RDF.type, type)) do |statement|
        properties[statement.subject.to_s] = DOWL::Property.new(statement.subject, self)
      end      
      return properties      
    end
    
    public
    def properties()
      return @datatype_properties.merge( @object_properties )     
    end
    
    public
    def list_properties()
      return properties().sort { |x,y| x[1] <=> y[1] }          
    end
    
    public
    def list_datatype_properties()
      return datatype_properties().sort { |x,y| x[1] <=> y[1] }
    end
    
    public
    def hasClasses?
      return ! @classes.empty?
    end 
    
    public
    def list_object_properties()
      return object_properties().sort { |x,y| x[1] <=> y[1] }
    end    
    
    #Return sorted, nested array
    public
    def list_classes()
      sorted = classes().sort { |x,y| x[1] <=> y[1] }
      return sorted      
    end
    
    public
    #
    # Return the class with the given URI as it is defined in this schema.
    # Do not check the imported ontologies.
    #
    def classInSchemaWithURI(uri_)
      return classes[uri_.to_s]
    end
    
    public
    #
    # See DOWL::Individual::classWithURI(uri)
    #
    def classWithURI(uri)
      if @ontology
        return @ontology.classWithURI(uri)
      end
      klass = classInSchemaWithURI(uri)
      if klass
        return klass
      end
      return nil
    end    
    
    public
    def root_classes()
      allClasses = classes().collect() do |uri,klass|
        klass
      end
      return allClasses.to_set.delete_if() do |klass|
        klass.hasSuperClassesInSchema?
      end
    end

    private
    def init_ontology()
      ontology = @model.first_subject(RDF::Query::Pattern.new(nil, RDF.type, DOWL::Namespaces::OWL.Ontology))
      if ontology
        @ontology = Ontology.new(ontology, self)
      else
        raise "ERROR: Ontology not found in schema"
      end
    end
    
    private
    def init_name()
      @name = nil    
      if @ontology
        prefix, ns = prefixForNamespace(@ontology.uri())
        if prefix
          @name = prefix.to_s
        end
      end
      if @name.nil? and @ontology
        #
        # Searching for vann:preferredNamespacePrefix to use as the name for the schema
        #
        prefix = @ontology.get_literal(DOWL::Namespaces::VANN.preferredNamespacePrefix)
        if prefix
          @name = prefix.to_s
          if @options.verbose
            puts "Found vann:preferredNamespacePrefix: #{prefix}"
          end
          #
          # Add the found prefix to the collection of prefixes/namespaces
          # (perhaps we should search for vann:preferredNamespaceUri to make it complete)
          #
          ns = @ontology.get_literal(DOWL::Namespaces::VANN.preferredNamespaceUri)
          if ns
            prefixes[@name] = ns
          else
            prefixes[@name] = @ontology.ns
          end
        else
          warn "WARNING: vann:preferredNamespacePrefix not found"
        end
      end
      if @name.nil? and @ontology
        @name = @ontology.escaped_short_name()
      end
      if (@name.nil? or @name.empty?())
        raise "ERROR: No name found for the schema"
      end
    end
    
    #
    # Replace the namespace in the given uri with the corresponding prefix, if defined
    #
    public
    def prefixedUri(uri)
      if uri.nil?
        raise "ERROR: Passed nil to Schema:prefixedUri()"
      end
      uri = uri.to_s()
      if uri.empty?
        raise "ERROR: Passed empty string to Schema:prefixedUri()"
      end
      uri = uri.gsub(",", "_")
      @prefixes.each() do |prefix, namespace|
        if uri == namespace
          return prefix.to_s
        end
        if "#{uri}/" == namespace
          return prefix.to_s
        end
        if "#{uri}#" == namespace
          return prefix.to_s
        end
        if namespace[-1..-1] != '#' and namespace[-1..-1] != '/'
          raise "ERROR: Namespace in @prefixes without trailing hash or slash: #{namespace}"
        end
        if uri.include?(namespace)
          if @ontology and namespace == @ontology.ns
            return uri.gsub(namespace, '')
          end
          return uri.gsub(namespace, "#{prefix.to_s}:")
        end
      end
      if @ontology
        ontology_uri = @ontology.uri
        if ontology_uri == uri
          return uri
        end
        uri = uri.gsub(ontology_uri + '#', '')
        uri = uri.gsub(ontology_uri + '/', '')
      end
      return uri
    end

    public
    #
    # Generate the main Class Diagram
    #
    def classDiagramAsSvg
      if @options.verbose
        puts "Generating SVG Class Diagram for #{name}"
      end

      g = GraphvizUtility.setDefaults(GraphViz.new(:G, :type => :digraph))
      g[:rankdir] = "LR"
      sg = g.subgraph() { |sg|
        sg[:rank => "same"]
      }
      
      nodes = Hash.new
      edges = Hash.new
      allClasses = classes.values.to_set
      nonRootClasses = allClasses
      rootClasses = root_classes.to_set
      
      #
      # Add the GraphViz nodes for each class, but do the 
      # root classes in a subgraph to keep them at top level
      #
      rootClasses.each() do |klass|
        nonRootClasses.delete(klass)
        nodes, edges = klass.addAsGraphvizNode(sg, nodes, edges)
      end
      nonRootClasses.each() do |klass|
        nodes, edges = klass.addAsGraphvizNode(g, nodes, edges)
      end
      #
      # Process edges to super classes, we can ignore the root classes here
      #
      nonRootClasses.each() do |klass|
        if @options.verbose
          puts "- Processing class #{klass.short_name}"
        end
        superClasses = klass.super_classes() 
        superClasses.each() do |superClass|
          superClassNode = nodes[superClass.uri]
          if superClassNode
            if @options.verbose
              puts "  - Processing super class #{superClass.short_name}"
            end
            Class.newGraphVizEdge(g, nodes[klass.uri], superClassNode)
          else
            if @options.verbose
              puts "  - Processing super class #{superClass.short_name}, not found"
            end
          end
        end
      end
      #
      # Process the other associations here
      #
      allClasses.each() do |domainClass|
        domainClassNode = nodes[domainClass.uri]
        if @options.verbose
          puts "  - Processing associations of class #{domainClass.short_name}:"
        end
        domainClass.associations().each() do |association|
          if @options.verbose
            puts "    - Adding edge #{association.rangeClass.short_name}, #{association.label}"
          end
          nodes, edges = association.addAsGraphVizEdge(g, nodes, edges)
        end
      end
      
      return GraphvizUtility.embeddableSvg(g)
    end

    public
    def individuals
      if not defined?(@individuals)
        init_individuals
      end
      return @individuals
    end
    
    private
    def init_individuals
     
      @individuals = Hash.new
 
      if @options.verbose
        puts "Searching for Individuals in schema #{@name}"
      end
      
      #   FILTER (?type != owl:NamedIndividual && regex(str(?resource), "r29-.*"))
      sparql = <<sparql
        SELECT DISTINCT * WHERE { 
          ?resource a owl:NamedIndividual .
          ?resource a ?type .
          FILTER (?type != owl:NamedIndividual)
          }
sparql
      solutions = SPARQL.execute(sparql, @model, { :prefixes => @prefixes })
      if @options.verbose
        puts " - Found #{solutions.count} Individuals"
      end
 
      solutions.each do |solution|
        Individual.withUri(solution[:resource], self)
      end
      if @options.verbose
        puts "Initialized All Individuals in #{@name}"
      end
    end
    
  end  
  
end
