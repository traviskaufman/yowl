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
        generateOntologyHtmlFile(schema)
        generateOntologyDotFiles(schema)
      end
    end
    
    private
    def generateOntologyHtmlFile(schema)
      if @options.verbose
        puts "Generating documentation for ontology #{schema.ontology.title}"
      end
      introduction = @introduction
      relative_url_html = "#{schema.name}.html"
      relative_url_svg  = "#{schema.name}.svg"
      b = binding
      output_file = File.join(@options.html_output_dir, relative_url_html)
      if @options.verbose
        puts "Generating #{output_file}"
      end
      File.open(output_file, 'w') do |file|
        file.write(@ontology_template.result(b))
      end
    end

    private
    def generateOntologyDotFiles(schema)
      output_file_dot = File.join(@options.html_output_dir, "#{schema.name}.dot")
      output_file_svg = File.join(@options.html_output_dir, "#{schema.name}.svg")
      #
      # Serializing RDF statements into a Graphviz file
      #
      RDF::Writer.open(output_file_dot) do |writer|
        schema.model.each_statement do |statement|
          writer << statement
        end
      end
      GraphViz.parse(output_file_dot).output(:svg => output_file_svg)
    end
    
    private
    def ontologies()
      ontologies = []
      @schemas.each() do |schema|
        ontologies << schema.ontology
      end
      return ontologies.sort { |x,y| x.short_name <=> y.short_name }
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
      ontologies = ontologies()
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
