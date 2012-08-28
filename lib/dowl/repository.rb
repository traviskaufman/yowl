module DOWL
  class Repository
    
    attr_reader :schemas
    attr_reader :options

    def initialize(options)
      @options = options
      
      init_schemas()
    end
    
    private
    def init_schemas()
      @schemas = []
        
      @options.ontology_file_names.each() do | ontology_file_name |
        if options.verbose
          puts "Parsing #{ontology_file_name}"
        end
        schema = Schema.fromFile(ontology_file_name, self)
        if schema
          schemas << schema
        end
      end
    end  
    
    public
    def ontologies()
      ontologies = []
      @schemas.each() do |schema|
        ontologies << schema.ontology
      end
      return ontologies.sort { |x,y| x.short_name <=> y.short_name }
    end
 
    public
    def getSchemaForImport(import)
      importUri = import.uri
      @schemas.each() do |schema|
        if schema.uri == importUri
          return schema
        end
      end
      return nil
    end
       
    public
    def knowsImport(import)
      return ! getSchemaForImport(import).nil?
    end
    
    public
    def getSchemaNameForImport(import)
      schema = getSchemaForImport(import)
      return schema.nil? ? '' : schema.name
    end
    
    public
    def ontologiesAsSvg
      if @options.verbose
        puts "Generating SVG for Ontology Import Diagram"
      end
      g = GraphViz.new(:G, :type => :digraph)
      g[:rankdir] = "BT"
      nodes = {}
      ontologies.each() do |ontology|
        nodeID = ontology.escaped_uri
        node = g.add_nodes(nodeID)
        node.URL = "../ontology/#{ontology.resourceNameHtml}"
        node.label = ontology.short_name
        nodes[nodeID] = node
      end
      ontologies.each() do |ontology|
        if @options.verbose
          puts "- Processing ontology #{ontology.escaped_uri}"
        end
        ontology.imports.each() do |import|
          importNode = nodes[import.escaped_uri]
          if importNode
            if @options.verbose
              puts "  - Processing import #{import.escaped_uri}"
            end
            g.add_edges(nodes[ontology.escaped_uri], importNode)
          else
            if @options.verbose
              puts "  - Processing import #{import.escaped_uri}, not found"
            end
          end
        end
      end
      puts g.output(:dot => nil)
      return g.output(:svg => String)      
    end
    
  end
end