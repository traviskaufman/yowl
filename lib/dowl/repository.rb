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
      nodes = {}
      ontologies.each() do |ontology|
        node = g.add_nodes(ontology.escaped_short_name)
        node.URL = ontology.uri.to_s
        nodes[ontology.escaped_short_name] = node
      end
      ontologies.each() do |ontology|
        if @options.verbose
          puts "- Processing ontology #{ontology.escaped_short_name}"
        end
        ontology.imports.each() do |import|
          if @options.verbose
            puts "  - Processing import #{import.escaped_short_name}"
          end
          importNode = nodes[import.escaped_short_name]
          if importNode
            g.add_edges(nodes[ontology.escaped_short_name], importNode)
          end
        end
      end
      return g.output(:svg => String)      
    end
    
  end
end