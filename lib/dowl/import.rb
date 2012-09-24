require 'dowl'

module DOWL

  class Import < DOWL::LabelledDocObject
    
    attr_reader :importedSchema
    attr_reader :importedOntology
 
    def initialize(resource_, schema_)
      super(resource_, schema_)
      
      @importedSchema = schema_.repository.getSchemaForImport(self)
      @importedOntology = @importedSchema ? @importedSchema.ontology : nil
      
      if @importedSchema.nil?
        puts "WARNING: Created Import #{uri} but did not find schema for it "
      end
      if @importedOntology.nil?
        puts "WARNING: Created Import #{uri} but did not find ontology for it "
      end
    end
    
    def name
      if @importedSchema
        return @importedSchema.name
      end
      prefix, ns = @schema.prefixForNamespace(uri)
      if prefix
        return prefix
      end
      return short_name
    end
    
    def resourceNameHtml
      return "#{@name}.html"
    end
    
    def imports
      return @importedOntology ? @importedOntology.imports : []
    end
    
    def isExternal?
      return (@importedSchema.nil? and @importedOntology.nil?)
    end

    #
    # See DOWL::Individual::classWithURI(uri)
    #    
    def classWithURI(uri_)
      if isExternal?
        return nil
      end
      if @importedSchema
        return @importedSchema.classWithURI(uri_)
      end
      puts "WARNING: Cannot check whether class #{uri_.to_s} exists in imported ontology #{uri} as this ontology is not loaded"
      return nil
    end

  end
end
