module YOWL
  class Association < YOWL::LabelledDocObject

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
    def addAsGraphVizEdge(graph_, nodes_, edges_)

      if not nodes_.has_key?(@domainClass.uri)
        return nodes_, edges_
      end
      if not nodes_.has_key?(@rangeClass.uri)
        return nodes_, edges_
      end
      if edges_.has_key?(@key)
        return nodes_, edges_
      end

      domainClassNode = nodes_[@domainClass.uri]
      rangeClassNode = nodes_[@rangeClass.uri]

      edges_[@key] = Association.newGraphVizEdge(graph_, domainClassNode, rangeClassNode, label)

      return nodes_, edges_
    end

    def Association.newGraphVizEdge(graph_, domainNode_, rangeNode_, label_, constraint_ = true)
      return graph_.add_edges(
        domainNode_,
        rangeNode_,
        :label => label_, 
        :arrowhead => :open, 
        :arrowsize => 0.5,
        :penwidth => 0.5,
        :constraint => constraint_
      )
    end
  end
end
