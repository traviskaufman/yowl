require 'dowl'

module DOWL

  class Import < DOWL::LabelledDocObject
    
    attr_reader :importedOntology
 
    def initialize(resource, schema)
      super(resource, schema)
      
      importedSchema = @schema.repository.getSchemaForImport(self)
      @importedOntology = importedSchema ? importedSchema.ontology : nil
    end
    
    def name
      if @importedOntology
        return @schema.name
      end
      prefix = @schema.prefixForNamespace(uri)
      if prefix
        return prefix
      end
      return @schema.name
    end
    
    def resourceNameHtml
      return "#{@name}.html"
    end
    
    def imports
      return @importedOntology ? @importedOntology.imports : []
    end

    #
    # See DOWL::Individual::classWithURI(uri)
    #    
    def classWithURI(uri)
      if @importedOntology
        return @importedOntology.classWithURI(uri)
      end
      puts "WARNING: Cannot check whether class #{uri.to_s} exists in imported ontology #{uri} as this ontology is not loaded"
      return nil
    end

  end
end
