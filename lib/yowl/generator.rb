module YOWL

  class Generator

    def initialize(repository, options)
      @options = options
      @repository = repository
    end

    private
    def generateOntologyHtmlFiles()
      @repository.schemas.values.each() do |schema|
        generateOntologyHtmlFile(schema)
      end
    end

    private
    def generateOntologyHtmlFile(schema)
      if @options.verbose
        puts "Generating documentation for ontology #{schema.ontology.title}"
      end

      introduction  = @introduction
      repository    = @repository

      b = binding

      begin
        Dir.mkdir(@options.output_dir)
      rescue Errno::EEXIST
      end

      ontologyFile = File.join(@options.output_dir, "#{schema.name}.html")
      if @options.verbose
        puts "Generating #{ontologyFile}"
      end
      File.open(ontologyFile, 'w') do |file|
        file.write(@options.templates['ontology'].result(b))
      end
    end

    private
    def generateHtmlFile(templateName_)

      template = @options.templates[templateName_]

      if template.nil?
        puts "Not generating #{templateName_}.html since #{templateName_} template could not be found."
        return
      end
      fileName = File.join(@options.output_dir, "#{templateName_}.html")
      if @options.verbose
        puts "Generating #{fileName}"
      end

      repository  = @repository
      schemas     = @repository.schemas.values
      ontologies  = @repository.ontologies()

      b = binding

      File.open(fileName, 'w') do |file|
        file.write(template.result(b))
      end
    end

    private
    def copyTemplateDir(src_, tgt_)
      return unless File.directory? "#{src_}"

      Dir.mkdir tgt_ unless File.directory? tgt_
      puts "Copying #{src_} -> #{tgt_}"
      FileUtils.cp_r src_, tgt_
    end

    private
    def copyTemplates()

      @options.template_dirs.each do |template_dir|
        copyTemplateDir("#{template_dir}/js",     "#{@options.output_dir}")
        copyTemplateDir("#{template_dir}/css",    "#{@options.output_dir}")
        copyTemplateDir("#{template_dir}/themes", "#{@options.output_dir}")
        copyTemplateDir("#{template_dir}/img",    "#{@options.output_dir}")
      end
    end

    public
    def run()
      copyTemplates()
      generateHtmlFile('index')
      generateHtmlFile('introduction')
      generateHtmlFile('import-diagram')
      generateOntologyHtmlFiles()
    end
  end
end
