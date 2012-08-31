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
      return @schema.name
    end
    
    def resourceNameHtml
      
      return "#{@name}.html"
    end
    
    def imports
      return @importedOntology ? @importedOntology.imports : []
    end

  end
end
