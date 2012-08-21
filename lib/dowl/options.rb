module DOWL
  #
  # Utility class representing all specified command line options
  #
  class Options
    
    attr_accessor :ontology_file_names
    attr_accessor :html_output_dir
    attr_accessor :index_file_name
    attr_accessor :ontology_template_file_name
    attr_accessor :index_template_file_name
    attr_accessor :introduction_file_name
    attr_reader :ontology_template
    attr_reader :index_template
    attr_reader :introduction
    attr_accessor :verbose
    
    def initialize()
      @verbose = false
      @ontology_file_names = []
      @html_output_dir = Dir.pwd()
      @index_file_name = nil
      @ontology_template_file_name = nil
      @index_template_file_name = nil
      @introduction_file_name = nil
      @ontology_template = nil
      @index_template = nil
      @introduction = nil
    end
    
    def validate()
      if ! validate_ontology_file_names()
        return false
      end
      if ! validate_ontology_template()
        return false
      end
      if ! validate_index_template()
        return false
      end
      if ! validate_introduction()
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
      end
      return true
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
    def validate_ontology_template_file_name(filename)
      if verbose()
        puts "Checking ontology template #{filename}"
      end
      if File.exists?(filename)
        File.open(filename) do |file|
          @ontology_template = ERB.new(file.read)
        end
        if verbose()
          puts "Found and read ontology template #{filename}"
        end
        return true
      end
      return false
    end

    private
    def validate_index_template_file_name(filename)
      if verbose()
        puts "Checking index template #{filename}"
      end
      if File.exists?(filename)
        File.open(filename) do |file|
          @index_template = ERB.new(file.read)
        end
        if verbose()
          puts "Found and read index template #{filename}"
        end
        return true
      end
      return false
    end
    
    private
    def validate_ontology_template()
      
      if @ontology_template_file_name != nil
        if validate_ontology_template_file_name(@ontology_template_file_name)
          return true
        end
        warn "ERROR: Could not find ontology template #{ontology_template_file_name}"
        return false
      end
      
      if validate_ontology_template_file_name(File.join(ontology_dir(), "dowl/default.erb"))
        return true
      end

      if validate_ontology_template_file_name(File.join(File.dirname(__FILE__), "default.erb"))
        return true
      end
      
      warn "Could not find ontology template"
      return false
    end
    
    private
    def validate_index_template()
      
      if @index_template_file_name != nil
        if validate_index_template_file_name(@index_template_file_name)
          return true
        end
        warn "ERROR: Could not find index template #{index_template_file_name}"
        return false
      end
      
      if validate_index_template_file_name(File.join(ontology_dir(), "dowl/index.erb"))
        return true
      end
  
      if validate_index_template_file_name(File.join(File.dirname(__FILE__), "index.erb"))
        return true
      end
      
      warn "Could not find index template"
      return false
    end
    
    private
    def validate_introduction_file_name(filename)
      if verbose()
        puts "Checking introduction template #{filename}"
      end
      if File.exists?(filename)
        File.open(filename) do |file|
          @introduction = file.read
        end
        if verbose()
          puts "Found and read introduction template #{filename}"
        end
        return true
      end
      return false
    end
    
    private
    def validate_introduction()
      
      if @introduction_file_name != nil
        if validate_introduction_file_name(@introduction_file_name)
          return true
        end
        warn "ERROR: Could not find #{@introduction_file_name}"
        return false
      end
      
      if validate_introduction_file_name(File.join(ontology_dir(), "introduction.html"))
        return true
      end

      if validate_introduction_file_name(File.join(ontology_dir(), "dowl/introduction.html"))
        return true
      end
      
      if validate_introduction_file_name(File.join(File.dirname(__FILE__), "introduction.html"))
        return true
      end
      
      return true
    end
    
  end # End of class Options
end # End of module DOWL