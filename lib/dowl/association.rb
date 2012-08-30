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
        
        domainClassNode = nodes[@domainClass.uri]
        rangeClassNode = nodes[@rangeClass.uri]
          
        #graph.add_edges(domainClassNode, rangeClassNode, :label => label)
        graph.add_edges(domainClassNode, rangeClassNode)
      end
    end
end