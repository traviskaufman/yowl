module DOWL
  class IndividualAssociation < DOWL::LabelledDocObject

    attr_reader :domainIndividual
    attr_reader :rangeIndividual
    attr_reader :property
    attr_reader :key
    
    def initialize(resource, schema, domainIndividual, rangeIndividual)
      
      if resource.nil?
        raise "Problem"
      end
      super(resource, schema)
      
      @domainIndividual = domainIndividual
      @rangeIndividual = rangeIndividual

      @key = "#{@domainIndividual.uri},#{@rangeIndividual.uri},#{label}".hash
      
      #puts "Created IndividualAssociation #{@domainIndividual.uri},#{@rangeIndividual.uri}, #{uri}"
    end

    def label
      return short_name
    end

    def hash
      return key
    end

    def eql?(other)
      @key.eql? other.key
    end

    #
    # Add the current IndividualAssociation as an edge to the given GraphViz graph,
    # but check whether the IndividualAssociation refers to a Domain and Range class in
    # the current schema and whether the IndividualAssociation has already been added
    # to the graph (by checking the given edges collection).
    #
    def addAsGraphVizEdge(graph_, nodes_, edges_, level_)
      
      if level_ < 1
        return nodes_, edges_
      end

      nodes_, edges_ = @domainIndividual.addAsGraphvizNode(graph_, nodes_, edges_, level_)
      nodes_, edges_ = @rangeIndividual.addAsGraphvizNode(graph_, nodes_, edges_, level_)
      
      if edges_.has_key?(@key)
        return nodes_, edges_
      end
      
      domainIndividualNode = nodes_[@domainIndividual.uri]
      rangeIndividualNode = nodes_[@rangeIndividual.uri]
      
      #
      # As the level_ parameter for the two calls to addAsGraphvizNode might have caused
      # that one or both of these nodes are not generated, we have to check for this here.
      #
      if domainIndividualNode.nil? or rangeIndividualNode.nil?
        return nodes_, edges_
      end
      
      edges_[@key] = graph_.add_edges(
        domainIndividualNode, 
        rangeIndividualNode, 
        :headlabel => label, 
        :arrowhead => :open, 
        :arrowsize => 0.5,
        :penwidth => 0.5
      )
      
      return nodes_, edges_
    end
  end
end
