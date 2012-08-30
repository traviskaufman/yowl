require 'rexml/document'

module DOWL
  #
  # Utility class providing access to information about the schema, e.g. its description, lists of classes, etc
  #
  class Schema
    
    attr_reader :options
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
      
      prefixes = Schema::read_prefixes(ontology_file_name)
      model = RDF::Graph.new(ontology_file_name, :prefixes => prefixes)
      model.load!
      
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
          prefixes[prefix] = namespace
        end
      end
      
      return prefixes
    end
    
    public
    def uri
      return @ontology.nil? ? nil : @ontology.uri
    end
    
    #
    # Return the prefix and the corresponding namespace for the given namespace,
    # where various forms of the given namespace are tried, like <ns>, <ns>/ and <ns>#.
    # When no namespace could be found, return two nils.
    public
    def prefixForNamespace(namespace_)
      @prefixes.each() do |prefix, namespace|
        if (namespace == namespace_ or namespace + '/' == namespace_ or namespace + '#' == namespace_)
          return prefix, namespace
        end
      end
      if @options.verbose
        puts "No prefix found for namespace #{namespace_}"
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
          @name = prefix
        end
      end
      if @name.nil? and @ontology
        #
        # Searching for vann:preferredNamespacePrefix to use as the name for the schema
        #
        prefix = @ontology.get_literal(DOWL::Namespaces::VANN.preferredNamespacePrefix)
        if prefix
          @name = prefix
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
      @prefixes.each() do |prefix, namespace|
        if uri == namespace
          return prefix
        end
        if "#{uri}/" == namespace
          return prefix
        end
        if "#{uri}#" == namespace
          return prefix
        end
        if uri.include?(namespace)
          if @ontology and namespace == @ontology.ns
            return uri.gsub(namespace, '')
          end
          return uri.gsub(namespace, "#{prefix}:")
        end
      end
      if @ontology
        ontology_uri = @ontology.uri
        if ontology_uri == uri
          return uri
        end
        uri = uri.gsub(ontology_uri + '#', '')
        uri = uri.gsub(ontology_uri + '/', '')
        return uri.gsub(ontology_uri, '')
      end
      return uri
    end

    private
    def classDiagramAddNode(nodes, graph, klass)
      if @options.verbose
        puts "- Processing class #{klass.short_name}"
      end
      node = graph.add_nodes(klass.escaped_uri)
      node.URL = "#class_#{klass.short_name}"
      name = klass.short_name
      
      if name.include?(':')
        prefix = name.sub(/:\s*(.*)/, "")
        name = name.sub(/(.*)\s*:/, "")
        #
        # Can't get HTML labels to work
        #
        #node.label = "<TABLE BORDER=\"0\" CELLBORDER=\"1\" CELLSPACING=\"0\"><TR><TD>#{name}</TD></TR><TR><TD><I>(#{prefix})</I></TD></TR></TABLE>"
        node.label = "#{name}\n(#{prefix})"
      else
        node.label = name
      end 
      if klass.hasComment?
        node.tooltip = klass.comment
      end
      nodes[klass.uri] = node
      return nodes
    end
        
    public
    def classDiagramAsSvg
      if @options.verbose
        puts "Generating SVG Class Diagram for #{name}"
      end

      g = GraphvizUtility.setDefaults(GraphViz.new(:G, :type => :digraph))
      sg = g.subgraph() { |sg|
        sg[:rank => "same"]
      }
      
      nodes = {}
      allClasses = classes().collect() do |uri,klass|
        klass
      end
      nonRootClasses = allClasses 
      rootClasses = root_classes()
      
      rootClasses.each() do |klass|
        nonRootClasses.delete(klass)
        nodes = classDiagramAddNode(nodes, sg, klass)
      end
      allClasses.each() do |klass|
        nodes = classDiagramAddNode(nodes, g, klass)
      end
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
            g.add_edges(nodes[klass.uri], superClassNode)
          else
            if @options.verbose
              puts "  - Processing super class #{superClass.short_name}, not found"
            end
          end
        end
        allClasses.each() do |domainClass|
          domainClassNode = nodes[klass.uri]
          klass.associations().each() do |association|
            edge = g.add_edges(domainClassNode, nodes[association.rangeClass.uri])
            #edge.label = association.label
          end
        end
      end
      
#     puts g.output(:dot => nil)
      return GraphvizUtility.embeddableSvg(g)
    end

  end  

end
