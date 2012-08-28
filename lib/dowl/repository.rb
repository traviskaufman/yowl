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
      g = GraphViz.new(:G, :type => :digraph)
      nodes = {}
      ontologies.each() do |ontology|
        nodes[ontology.escaped_short_name] = g.add_nodes(ontology.escaped_short_name)
      end
      ontologies.each() do |ontology|
        ontology.imports.each() do |import|
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