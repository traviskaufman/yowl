module DOWL
  #
  # Represents an Individual defined in the schema
  #  
  class Individual < DOWL::LabelledDocObject
    
    private
    def initialize(resource, schema)
      super(resource, schema)
      if schema.options.verbose
        puts "Created Individual #{short_name}"
      end
    end
   
    public
    def Individual.withUri(resource, schema)
      if resource.anonymous?
        warn "WARNING: Ignoring Individual with uri #{resource.to_s}"
        return
      end
      individual = schema.individuals[resource.to_s]
      if individual
        return individual
      end
      individual = Individual.new(resource, schema)
      schema.individuals[resource.to_s] = individual
      return individual
    end
        
    public
    #
    # This label is a bit different than the one in the base class as this one
    # gets its prefix stripped, if there is one.
    #
    def label
      @label ||= init_label
    end

    private 
    def init_label
      label = get_literal(DOWL::Namespaces::RDFS.label)
      if label
        return label
      end 
      label = short_name
      label = label.sub(/(.*)\s*:/, "")
      label = label.gsub("_", " ")

      return label
    end
   
    public
    #
    # The prefix to be used for the URI of this Individual, if defined, nil if it isn't
    #
    def prefix
      @prefix ||= init_prefix
    end

    private 
    def init_prefix
      name = short_name
      return name.include?(':') ? short_name.sub(/:\s*(.*)/, "") : nil
    end
    
    public
    def types
      @types ||= init_types
    end

    private
    def init_types
      types = []
      @schema.model.query(
        RDF::Query::Pattern.new(@resource, RDF.type)
      ) do |statement|
        if statement.object == DOWL::Namespaces::OWL.NamedIndividual
          next
        end
        types << statement.object
        puts "Found Type #{statement.object.to_s} for Individual #{label}"
      end
      return types
    end
   
    public
    def classes
      @classes ||= init_classes
    end

    private 
    def init_classes
      classes = []
      types.each do |type|
        klass = @schema.classWithURI(type)
        if klass
          classes << klass
          puts "Found Class #{klass.short_name} for Individual #{label}"
        else
          puts "WARNING: Could not find Class definition for URI #{type.to_s}"
        end
      end
      return classes
    end
    
    public
    #
    # Return a collection of Associations representing ObjectProperties
    # where the current class is one of the Domain classes.
    #
    def associatedIndividuals
      @associatedIndividuals ||= init_associatedIndividuals
    end
    
    private
    def init_associatedIndividuals()
      associations = Set.new

      if @schema.options.verbose
        puts "Searching for associations of Individual #{short_name}"
      end

      sparql = <<sparql
        SELECT DISTINCT ?individual WHERE { 
          ?individual a owl:NamedIndividual .
          ?individual ?predicate <#{uri}> .
        }
sparql
      if @options.verbose
        puts " - SPARQL: #{sparql}"
      end
      solutions = SPARQL.execute(sparql, @schema.model, { :prefixes => @schema.prefixes })
      if @options.verbose
        puts " - Found #{solutions.count} associated Individuals"
      end
      
      solutions.each do |solution|
        individual = solution[:individual]
        if @schema.options.verbose
          puts " - Found Individual #{individual.to_s}"
        end
        if rangeClass
          associations[individual.to_s] << Individual.withUri(individual, @schema)
        end
      end
      return associations
    end
    
    public
    #
    # Add the current Individual as a GraphViz node to the given collection of nodes
    # and to the given graph. Return the collection of nodes.
    #    
    def addAsGraphvizNode (nodes, graph)
      if @schema.options.verbose
        puts "- Processing Individual #{label}"
      end
      #
      # No need to add a node twice
      #
      if nodes.has_key?(uri)
        return nodes
      end
      node = graph.add_nodes(escaped_uri)
      #node.URL = "#individual#{short_name}"
      
      if prefix
        node.label = "#{label}\n(#{prefix})"
      else
        node.label = label
      end 
      #if hasComment?
      #  node.tooltip = comment
      #end
      nodes[uri] = node
      return nodes
    end    
    
    public
    #
    # Generate a diagram for each Individual
    #
    def asSvg
      if @schema.options.verbose
        puts "Generating SVG for Individual #{short_name}"
      end
    
      g = GraphvizUtility.setDefaults(GraphViz.new(:G, :type => :digraph))
      g[:rankdir] = "LR"
      g.node[:fixedsize] = false
      
      nodes = Hash.new
      edges = Hash.new
      nodes = addAsGraphvizNode(nodes, g)
      
      individualNode = nodes[uri]
      
      classes.each do |klass|
        nodes = klass.addAsGraphvizNode(nodes, g)
        klassNode = nodes[klass.uri]
        g.add_edges(individualNode, klassNode)
      end
      
      associatedIndividuals.each do |individual|
        individual.addAsGraphvizNode(nodes, g)
      end
      
      return GraphvizUtility.embeddableSvg(g)
    end
  end
end
