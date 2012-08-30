module DOWL
  
  class Association < DOWL::LabelledDocObject
  
      attr_reader :domainClass
      attr_reader :rangeClass
      attr_reader :property
      attr_reader :hash
      
      def initialize(resource, schema, domainClass, rangeClass)
        super(resource, schema)
        @domainClass = domainClass
        @rangeClass = rangeClass
        
        @hash = "#{@domainClass.uri},#{@rangeClass.uri},#{@resource.to_s}".hash 
      end
  
      def label
        return short_name
      end
      
      def addAsGraphVizEdge(graph, nodes)
        
        domainClassNode = nodes[@domainClass.uri]
        rangeClassNode = nodes[@rangeClass.uri]
          
        graph.add_edges(domainClassNode, rangeClassNode, :label => label)
      end
    end
end