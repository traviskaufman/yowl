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
      
      label.sub!(/^r29-/, "") # TODO: Make this configurable via setting in ontology

      
      classes.each do |klass|
        label.chomp!("-#{klass.short_name}")
      end

      return label
    end
    
    private
    def gvLabel
      tmp = label.gsub(", ", ",\n")
      return prefix ? "#{tmp}\n(#{prefix})" : tmp
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
      if not defined?(@types)
        init_types
      end
      return @types
    end

    private
    def init_types
      @types = []
      @schema.model.query(
        RDF::Query::Pattern.new(@resource, RDF.type)
      ) do |statement|
        if statement.object == DOWL::Namespaces::OWL.NamedIndividual
          next
        end
        @types << statement.object
        if @schema.options.verbose
          puts "Found Type #{statement.object.to_s} for Individual #{label}"
        end
      end
    end
   
    public
    def classes
      if not defined?(@classes)
        init_classes
      end
      return @classes
    end

    private 
    def init_classes
      @classes = []
      types.each do |type|
        klass = @schema.classWithURI(type)
        if klass
          @classes << klass
          if @schema.options.verbose
            puts "Found Class #{klass.short_name} for Individual #{label}"
          end
        else
          puts "WARNING: Could not find Class definition for URI #{type.to_s}"
        end
      end
    end
    
    public
    #
    # Return a collection of Associations representing ObjectProperties
    # where the current class is one of the Domain classes.
    #
    def associatedIndividuals
      if not defined?(@associatedIndividuals)
        init_associatedIndividuals
      end
      return @associatedIndividuals
    end
    
    private
    def init_associatedIndividuals()
      @associatedIndividuals = Hash.new

      if @schema.options.verbose
        puts "Searching for associations of Individual #{short_name}"
      end

      sparql = <<sparql
        SELECT DISTINCT ?individual WHERE {
          {
            ?individual a owl:NamedIndividual .
            ?individual ?predicateA <#{uri}> .
          } UNION {
            <#{uri}>
              a owl:NamedIndividual ;
              ?predicateB ?individual ;
            .
            ?individual a owl:NamedIndividual .
          }
        }
sparql
      #if @schema.options.verbose
      #  puts " - SPARQL: #{sparql}"
      #end
      solutions = SPARQL.execute(sparql, @schema.model, { :prefixes => @schema.prefixes })
      if @schema.options.verbose
        puts " - Found #{solutions.count} associated Individuals"
      end
      
      solutions.each do |solution|
        individual = Individual.withUri(solution[:individual], @schema)
        if @schema.options.verbose
          puts " - Found Individual #{individual.short_name}"
        end
        @associatedIndividuals[individual.uri] = individual
      end
      return @associatedIndividuals
    end
    
    #
    # Return a collection of IndividualAssociations representing ObjectProperties
    # where the current Individual is the subject/resource.
    #
    def outboundAssociations()
      if defined?(@outboundAssociations)
        return @outboundAssociations
      end
      @outboundAssociations = Set.new
    
      if @schema.options.verbose
        puts "Searching for associations of individual #{short_name}"
      end

      sparql = <<sparql
        SELECT DISTINCT ?individual ?predicate WHERE {
          <#{uri}> 
            a owl:NamedIndividual ;
            ?predicate ?individual
          .
          ?individual a owl:NamedIndividual .
        }
sparql
          
      #if @schema.options.verbose
      #  puts " - SPARQL: #{sparql}"
      #end
      solutions = SPARQL.execute(sparql, @schema.model, { :prefixes => @schema.prefixes })
      if @schema.options.verbose
        puts " - Found #{solutions.count} associated 'outbound' Individual Associations"
      end
      
      solutions.each do |solution|
        individual = Individual.withUri(solution[:individual], @schema)
        predicate = solution[:predicate]
        @outboundAssociations << IndividualAssociation.new(predicate, @schema, self, individual)
      end
      if @schema.options.verbose
        puts " - Returning #{@outboundAssociations.size} associations for Individual #{short_name}"
      end
      return @outboundAssociations
    end

    #
    # Return a collection of IndividualAssociations representing ObjectProperties
    # where the current Individual is the object.
    #
    def inboundAssociations()
      if defined?(@inboundAssociations)
        return @inboundAssociations
      end
      @inboundAssociations = Set.new
    
      if @schema.options.verbose
        puts "Searching for 'inbound' associations of individual #{short_name}"
      end
    
      sparql = <<sparql
        SELECT DISTINCT ?individual ?predicate WHERE {
          ?individual 
            a owl:NamedIndividual ;
            ?predicate <#{uri}> 
          .
        }
sparql
      #if @schema.options.verbose
      #  puts " - SPARQL: #{sparql}"
      #end
      solutions = SPARQL.execute(sparql, @schema.model, { :prefixes => @schema.prefixes })
      if @schema.options.verbose
        puts " - Found #{solutions.count} associated 'inbound' Individual Associations"
      end
      
      solutions.each do |solution|
        individual = Individual.withUri(solution[:individual], @schema)
        predicate = solution[:predicate]
        @inboundAssociations << IndividualAssociation.new(predicate, @schema, individual, self)
      end
      if @schema.options.verbose
        puts " - Returning #{@inboundAssociations.size} associations for Individual #{short_name}"
      end
      return @inboundAssociations
    end
    
    public
    #
    # Add the current Individual as a GraphViz node to the given collection of nodes
    # and to the given graph. Return the collection of nodes.
    #    
    def addAsGraphvizNode (graph_, nodes_, edges_, level_, maxLevel_ = 0)
      if level_ < 1
        return nodes_, edges_
      end
      if @schema.options.verbose
        puts "- Processing Individual #{label}"
      end
      #
      # No need to add a node twice
      #
      if nodes_.has_key?(uri)
        return nodes_, edges_
      end
      options = {
        :label => gvLabel,
        :tooltip => uri,
        :peripheries => 1, 
        :margin => "0.11,0.055",
        :fontcolor => "black",
        :fontsize => 8,
        :penwidth => 0.5,
        :shape => :ellipse,
        :style => :filled,
        :color => "black",
        :fillcolor => "#FCFCFC"
      }
      if level_ == maxLevel_
        options[:color] = "red"
        options[:penwidth] = 1
      end
      node = graph_.add_nodes(escaped_uri, options)
      nodes_[uri] = node
      #node.URL = "#individual#{short_name}"
      
      node.label = gvLabel
      #if hasComment?
      #  node.tooltip = comment
      #end
      
      classes.each do |klass|
        nodes_, edges_ = klass.addAsGraphvizNode(graph_, nodes_, edges_)
        Class.newGraphVizEdge(graph_, node, nodes_[klass.uri], false)
      end

      inboundAssociations.each do |association|
        nodes_, edges_ = association.addAsGraphVizEdge(graph_, nodes_, edges_, level_ - 1)
      end
      
      outboundAssociations.each do |association|
        nodes_, edges_ = association.addAsGraphVizEdge(graph_, nodes_, edges_, level_ - 1)
      end

      return nodes_, edges_
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
      
      nodes  = Hash.new
      edges  = Hash.new

      nodes, edges = addAsGraphvizNode(g, nodes, edges, 5, 5)

      return GraphvizUtility.embeddableSvg(g)
    end
  end
end
