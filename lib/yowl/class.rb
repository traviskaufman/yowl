module YOWL

  class Class < YOWL::LabelledDocObject
    
    include Comparable

    attr_reader :resource
    attr_reader :subClasses
    attr_reader :associations

    private
    def initialize(resource, schema)
      super(resource, schema)
      @super_classes = nil
      @subClasses = nil
      @associations = nil
    end

    public
    def Class.withUri(resource, schema)
      if resource.anonymous?
        warn "WARNING: Ignoring class with uri #{resource.to_s}"
        return
      end
      klass = schema.classes[resource.to_s]
      if klass
        return klass
      end
      klass = Class.new(resource, schema)
      schema.classes[resource.to_s] = klass
      if schema.options.verbose
        puts "Created class #{klass.short_name}"
      end
      return klass
    end

    public
    def short_name()
      sn = super()
      if sn[0,7] == "http://" or sn[0,8] == "https://"
        if sn.include?('#')
          ns = sn.slice(/.*#/)
        else
          ns = sn.slice(/.*\//)
        end
        return sn[ns.length..-1]
      end
      return sn
    end

    public
    def super_classes()
      if not @super_classes.nil?
        return @super_classes
      end

      @super_classes = []

      @schema.model.query(
        RDF::Query::Pattern.new(@resource, YOWL::Namespaces::RDFS.subClassOf)
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
          superClass = Class.withUri(statement.object, @schema)
          if superClass
            if superClass != self
              @super_classes << superClass
            end
          else
            warn "WARNING: Could not find super class #{statement.object.to_s}"
          end
        end
      end
      return @super_classes
    end

    public
    def hasSuperClasses?
      return ! super_classes.empty?()
    end

    public
    def hasSuperClassesInSchema?
      super_classes.each() do |klass|
        if @schema.classes.include?(klass.uri)
          return true
        end
      end
      return false
    end

    public
    def subClasses()
      if @subClasses
        return @subClasses
      end
      @subClasses = Set.new

      @schema.model.query(
        RDF::Query::Pattern.new(nil, YOWL::Namespaces::RDFS.subClassOf, @resource)
      ) do |statement|
        subClass = Class.withUri(statement.subject, @schema)
        if subClass
          if subClass != self
            @subClasses << subClass
          end
        else
          warn "WARNING: Could not find sub class of #{short_name} with uri #{statement.subject.to_s}"
        end
      end
      #@subClasses.sort! { |x,y| x <=> y }
      return @subClasses
    end

    public
    def hasSubClasses?
      return ! subClasses.empty?()
    end

    public
    #
    # Return a collection of Associations representing ObjectProperties
    # where the current class is one of the Domain classes.
    #
    def associations()
      if not @associations.nil?
        return @associations
      end
      @associations = Set.new

      if @schema.options.verbose
        puts "Searching for associations of class #{short_name}"
      end

      query = RDF::Query.new({
        :property => {
          YOWL::Namespaces::RDFS.domain => @resource,
          RDF.type => YOWL::Namespaces::OWL.ObjectProperty,
          YOWL::Namespaces::RDFS.range => :range
        }
      })
        
      solutions = query.execute(@schema.model)
      if @schema.options.verbose
        puts " - Found #{solutions.count} solutions"
      end
      solutions.distinct!
      if @schema.options.verbose
        puts " - Found #{solutions.count} distinct solutions"
      end

      solutions.each do |solution|
        property = solution[:property]
        range = solution[:range]
        if @schema.options.verbose
          puts " - Found Association from #{short_name} to #{@schema.prefixedUri(range)}: #{@schema.prefixedUri(property.to_s)}"
        end
        rangeClass = Class.withUri(range, @schema)
        if @schema.options.verbose
          puts "   - Found this class for it: #{rangeClass}"
        end
        if rangeClass
          @associations << Association.new(property, @schema, self, rangeClass)
        end
      end
      if @schema.options.verbose
        puts " - Returning #{@associations.size} associations for class #{short_name}"
      end
      return @associations
    end
    
    public
    #
    # Add the current class as a GraphViz node to the given collection of nodes
    # and to the given graph. Return the collection of nodes.
    #    
    def addAsGraphvizNode (graph_, nodes_, edges_)
      name = short_name
      if @schema.options.verbose
        puts "- Processing class #{name}"
      end
      #
      # No need to add a node twice
      #
      if nodes_.has_key? uri
        return nodes_, edges_
      end
      node = graph_.add_nodes(escaped_uri)
      node.URL = "#class_#{short_name}"
      
      prefix = nil
      if name.include?(':')
        prefix = name.sub(/:\s*(.*)/, "")
        name = name.sub(/(.*)\s*:/, "")
      end
      name = name.split(/(?=[A-Z])/).join(' ')
      if prefix
        #
        # Can't get HTML labels to work
        #
        #name = "<TABLE BORDER=\"0\" CELLBORDER=\"1\" CELLSPACING=\"0\"><TR><TD>#{name}</TD></TR><TR><TD><I>(#{prefix})</I></TD></TR></TABLE>"
        name = "#{name}\n(#{prefix})"
      end
      node.label = name
      
      if hasComment?
        node.tooltip = comment
      else 
        if hasDefinition?
          node.tooltip = definition
        end
      end
      nodes_[uri] = node
      return nodes_, edges_
    end
    
    public
    #
    # Generate a diagram for each class, the "per class diagram"
    #
    def perClassDiagramAsSvg
      #if @schema.options.verbose
      #  puts "Generating SVG Per Class Diagram for #{short_name}"
      #end
    
      g = GraphvizUtility.setDefaults(GraphViz.new(:G, :type => :digraph))
      g[:rankdir] = "LR"
      g.node[:fixedsize] = false
      
      nodes = Hash.new
      edges = Hash.new
      nodes, edges = addAsGraphvizNode(g, nodes, edges)
      
      #
      # Do the "outbound" associations first
      #
      associations.each do |association|
        nodes, edges = association.rangeClass.addAsGraphvizNode(g, nodes, edges)
        nodes, edges = association.addAsGraphVizEdge(g, nodes, edges)
      end
      
      #
      # Then do the "inbound" associations
      #
      @schema.classes.values.to_set.each do |klass|
        klass.associations.each do |association|
          if self == association.rangeClass
            nodes, edges = association.rangeClass.addAsGraphvizNode(g, nodes, edges)
            nodes, edges = association.addAsGraphVizEdge(g, nodes, edges)
          end
        end
      end
      
      return GraphvizUtility.embeddableSvg(g)
    end
    
    #
    # Create the GraphVis Edge for all "is a" (rdf:type) associations from a node
    # (representing a Class or Individual) to another node (always representing a Class)
    #
    def Class.newGraphVizEdge(graph_, domainNode_, rangeNode_, constraint_ = true)
      options = {
        :arrowhead => :empty,
        :arrowsize => 0.5,  
        :dir => :back,
        :label => "is a", 
        :labeldistance => 2,
        :penwidth => 0.5,
        :constraint => constraint_
      }
      if not constraint_
        options[:style] = :dashed
      end
      return graph_.add_edges(
        rangeNode_,
        domainNode_,
        options
      )
    end

  end

end
