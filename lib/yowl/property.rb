require 'yowl'

module YOWL
  
  class Property < YOWL::LabelledDocObject
    
    def initialize(resource, schema)
      super(resource, schema)
    end
    
    def see_alsos()
       links = []
       @schema.model.query(
         RDF::Query::Pattern.new(@resource, YOWL::Namespaces::RDFS.seeAlso)
       ) do |statement|
         links << statement.object.to_s
       end       
       return links
    end
        
    def sub_property_of()
      parent = @schema.model.first_value(
        RDF::Query::Pattern.new(@resource, YOWL::Namespaces::RDFS.subPropertyOf)
      )
      if parent
        uri = parent.to_s
        if @schema.properties[uri]
          return @schema.properties[uri]
        else
          return uri
        end
      end
      return nil
    end
        
    def range()
      ranges = []
      @schema.model.query(
        RDF::Query::Pattern.new(@resource, YOWL::Namespaces::RDFS.range)
      ) do |statement|
        ranges << statement.object
      end  
      classes = []
      ranges.each do |o|
        if o.resource?
          uri = o.to_s        
          if @schema.classes[uri]
            classes << @schema.classes[uri]
          else
            classes << uri
          end
        end
      end
      return classes
    end

    def domain()
      domains = []
      @schema.model.query(
        RDF::Query::Pattern.new(@resource, YOWL::Namespaces::RDFS.domain)
      ) do |statement|
        domains << statement.object
      end  
      classes = []
      domains.each do |o|
        if o.resource?
          uri = o.to_s         
          if @schema.classes[uri]
            classes << @schema.classes[uri]
          else
            classes << uri
          end
        end
        #TODO union
      end
      return classes
    end
    
    def sub_properties()
      list = []
      @schema.model.query(
        RDF::Query::Pattern.new(nil, YOWL::Namespaces::RDFS.subPropertyOf, @resource)
      ) do |statement|
        list << YOWL::Property.new(statement.subject, @schema)
      end
      return list
    end           

    public
    #
    # Add the current class as a GraphViz node to the given collection of nodes
    # and to the given graph. Return the collection of nodes.
    #    
    def addAsGraphvizNode (graph_, nodes_, edges_)
      name = short_name
      if @schema.options.verbose
        puts "- Processing property #{name}"
      end
      #
      # No need to add a node twice
      #
      if nodes_.has_key? uri
        return nodes_, edges_
      end
      node = graph_.add_nodes(escaped_uri)
      node.URL = "#prop_#{short_name}"
      
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
      if hasComment?
        node.tooltip = comment
      end
      nodes_[uri] = node
      return nodes_, edges_
    end
    
    public
    #
    # Generate a diagram for each Property, the "per property diagram"
    #
    def perPropertyDiagramAsSvg
      #if @schema.options.verbose
      #  puts "Generating SVG Per Property Diagram for #{short_name}"
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
      #associations.each do |association|
      #  nodes, edges = association.rangeClass.addAsGraphvizNode(g, nodes, edges)
      #  nodes, edges = association.addAsGraphVizEdge(g, nodes, edges)
      #end
      
      #
      # Then do the "inbound" associations
      #
      #@schema.classes.values.to_set.each do |klass|
      #  klass.associations.each do |association|
      #    if self == association.rangeClass
      #      nodes, edges = association.rangeClass.addAsGraphvizNode(g, nodes, edges)
      #      nodes, edges = association.addAsGraphVizEdge(g, nodes, edges)
      #    end
      #  end
      #end
      
      return GraphvizUtility.embeddableSvg(g)
    end
    
    #
    # Create the GraphVis Edge for all "is a" (rdf:type) associations from a node
    # (representing a Class) to another node (always representing a Property)
    #
    def Property.newGraphVizEdge(graph_, domainNode_, rangeNode_, constraint_ = true)
      options = {
        :arrowhead => "empty", 
        :dir => "back",
        :label => "is a", 
        :arrowsize => 0.5,
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