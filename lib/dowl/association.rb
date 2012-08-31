module DOWL
  class Association < DOWL::LabelledDocObject

    attr_reader :domainClass
    attr_reader :rangeClass
    attr_reader :property
    attr_reader :key
    def initialize(resource, schema, domainClass, rangeClass)
      super(resource, schema)
      @domainClass = domainClass
      @rangeClass = rangeClass

      @key = "#{@domainClass.uri},#{@rangeClass.uri},#{label}".hash
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
    # Add the current Association as an edge to the given GraphViz graph,
    # but check whether the Association refers to a Domain and Range class in
    # the current schema and whether the Association has already been added
    # to the graph (by checking the given edges collection).
    #
    def addAsGraphVizEdge(edges, graph, nodes)

      if not nodes.has_key?(@domainClass.uri)
        return edges
      end
      if not nodes.has_key?(@rangeClass.uri)
        return edges
      end
      
      domainClassNode = nodes[@domainClass.uri]
      rangeClassNode = nodes[@rangeClass.uri]
        
      edges.each do |edge|
        if edge.node_one == domainClassNode and edge.node_two == rangeClassNode and edge[:label] == label
          return edges
        end
      end

      edges << graph.add_edges(domainClassNode, rangeClassNode, :xlabel => label, :arrowHead => :open)
      
      returne edges
    end
  end
end
