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
      
      def addAsGraphVizEdge(graph, nodes)

	if not nodes.has_key?(@domainClass.uri)
		return
	end
	if not nodes.has_key?(@rangeClass.uri)
		return
	end
        domainClassNode = nodes[@domainClass.uri]
        rangeClassNode = nodes[@rangeClass.uri]

        graph.add_edges(domainClassNode, rangeClassNode, :label => label)
      end
    end
end
