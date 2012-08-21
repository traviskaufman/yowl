module DOWL

  class Generator
    
    def initialize(schemas, options)
      @schemas = schemas
      @options = options
      @ontology_template = @options.ontology_template
      @index_template = @options.index_template
      @introduction = @options.introduction
    end
    
    private
    def generateOntologyHtmlFiles()
      @schemas.each() do |schema|
        if @options.verbose
          puts "Generating documentation for ontology #{schema.ontology.title}"
        end
        introduction = @introduction
        b = binding
        output_file = File.join(@options.html_output_dir, schema.name + '.html')
        if @options.verbose
          puts "Generating #{output_file}"
        end
        File.open(output_file, 'w') do |file|
          file.write(@ontology_template.result(b))
        end
      end
    end
    
    private
    def generateIndexHtmlFile()
      if @options.index_file_name == nil
        puts "Not generating index since index file name not specified."
        return
      end
      if @index_template == nil
        puts "Not generating index since index template not specified."
        return
      end
      if @options.verbose
        puts "Generating #{@options.index_file_name}"
      end
      schemas = @schemas
      b = binding
      File.open(@options.index_file_name, 'w') do |file|
        file.write(@index_template.result(b))
      end
    end
    
    public
    def run()
      generateOntologyHtmlFiles()
      generateIndexHtmlFile()      
    end
  end  
end
