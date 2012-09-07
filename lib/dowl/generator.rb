module DOWL

  class Generator
    
    def initialize(repository, options)
      @options = options
      @repository = repository
    end
    
    private
    def generateOntologyHtmlFiles()
      @repository.schemas.each() do |schema|
        generateOntologyHtmlFile(schema)
      end
    end
    
    private
    def generateOntologyHtmlFile(schema)
      if @options.verbose
        puts "Generating documentation for ontology #{schema.ontology.title}"
      end
      
      introduction = @introduction
      repository = @repository
      
      b = binding
      
      output_file = File.join(@options.output_dir, "#{schema.name}.html")
      if @options.verbose
        puts "Generating #{output_file}"
      end
      File.open(output_file, 'w') do |file|
        file.write(@options.templates['ontology'].result(b))
      end
    end
    
    private
    def generateIndexHtmlFile()
      
      if @options.templates['index'] == nil
        puts "Not generating index since index template not specified."
        return
      end
      if @options.verbose
        puts "Generating #{@options.index_file_name}"
      end
      
      repository = @repository
      schemas = @repository.schemas
      ontologies = @repository.ontologies()
      
      b = binding
      
      File.open(@options.index_file_name, 'w') do |file|
        file.write(@options.templates['index'].result(b))
      end
    end
    
    public
    def run()
      generateOntologyHtmlFiles()
      generateIndexHtmlFile()      
    end
  end  
end
