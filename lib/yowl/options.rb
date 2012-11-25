module YOWL
  #
  # Utility class representing all specified command line options
  #
  class Options
    
    attr_accessor :ontology_file_names
    attr_accessor :output_dir
    attr_accessor :template_dirs
    attr_accessor :noVann
    
    attr_reader :templates
    
    attr_accessor :verbose
    attr_accessor :quiet

    
    def initialize()
      @verbose = false
      @quiet = false
      @ontology_file_names = []
      @output_dir = Dir.pwd()
      @template_dirs = []
      @templates = Hash.new
      @noVann = false
    end
    
    def validate()
      if not @quiet
        puts "Output will be generated in this directory: #{output_dir.to_s}"
      end
      if ! validate_ontology_file_names()
        return false
      end
      if ! validate_template_dirs()
        return false
      end
      if ! validate_templates()
        return false
      end
      return true
    end
    
    private
    def validate_ontology_file_names
      if @ontology_file_names.empty?
        return false
      end
      @ontology_file_names.each() do |filename|
        if ! File.exists?(filename)
          warn "File does not exist: " + filename
          return false
        end
        if not @quiet
          puts "Will process input file: #{filename}"
        end
      end
      return true
    end
    
    private
    def validate_template_dirs
      @template_dirs << File.join(ontology_dir(), "yowl/template")
      @template_dirs << File.join(File.dirname(__FILE__), "template")
      @template_dirs = @template_dirs.find_all do |dir|
        Dir[dir]
      end
      return ! @template_dirs.empty?()
    end
    
    #
    # TODO: Either we support one template per ontology or
    # we support one template per input directory. That would
    # then be the only way to specify input ontologies: by directory.
    #
    private
    def ontology_dir()
      return File.dirname(@ontology_file_names[0])
    end
    
    private
    def load_template(templateName_, required_ = true)
      @template_dirs.each do |template_dir|
        templateFileName = File.join(template_dir, "#{templateName_}.erb")
        if verbose()
          puts "Checking template #{templateFileName}"
        end
        if File.exists?(templateFileName)
          File.open(templateFileName) do |file|
            @templates[templateName_] = ERB.new(file.read)
          end
          if verbose()
            puts "Loaded template #{templateFileName}"
          end
          return
        end
      end
      if required_
        raise "ERROR: #{templateName_} could not be found"
      end
    end
    
    private
    def validate_templates()
      
      load_template('index');
      #load_template('overview');
      load_template('introduction', false);
      load_template('import-diagram');
      load_template('ontology');
      
      return true
    end
    
  end # End of class Options
end # End of module YOWL
