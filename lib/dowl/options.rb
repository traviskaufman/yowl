module DOWL
  #
  # Utility class representing all specified command line options
  #
  class Options
    
    attr_accessor :ontology_file_names
    attr_accessor :html_output_dir
    attr_accessor :template_file_name
    attr_accessor :introduction_file_name
    attr_reader :template
    attr_reader :introduction
    
    def initialize()
      @ontology_file_names = []
      @html_output_dir = Dir.pwd()
      @template_file_name = nil
      @introduction_file_name = nil
      @template = nil
      @introduction = nil
    end
    
    def validate()
      if ! validate_ontology_file_names()
        return false
      end
      if ! validate_template()
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
    def validate_template_file_name(filename)
      if File.exists?(filename)
        @template_file_name = filename
        @template = File.new(filename)
        return true
      end
      return false
    end
    
    private
    def validate_template()
      
      if @template_file_name != nil
        if validate_template_file_name(@template_file_name)
          return true
        end
      end
      
      if validate_template_file_name(File.join(ontology_dir(), "dowl/default.erb"))
        return true
      end

      if validate_template_file_name(File.join(File.dirname(__FILE__), "default.erb"))
        return true
      end
      
      warn "Could not find template"
      return false
    end

    private
    def validate_introduction_file_name(filename)
      if File.exists?(filename)
        @introduction_file_name = filename
        @introduction = File.new(filename)
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
      
      warn "Could not find introduction html file"
      return false
    end
    
  end # End of class Options
end # End of module DOWL