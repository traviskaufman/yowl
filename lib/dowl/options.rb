module DOWL
  class Options
    
    attr_accessor :ontology_file_names
    attr_accessor :html_output_dir
    attr_accessor :template_file_name
    attr_reader :template
    
    def initialize ()
      @ontology_file_names = []
      @html_output_dir = Dir.pwd()
      @template_file_name = nil
    end
    
    def validate()
      if ! validate_ontology_file_names()
        return false
      end
      if ! validate_template()
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
    def ontology_dir
      return File.dirname(@ontology_file_names[0])
    end
    
    private
    def validate_template()
      
      if @template_file_name != nil
        if File.exists?(@template_file_name)
          @template = File.new(@template_file_name)
          return true
        end
      end
      
      @template_file_name = File.join(ontology_dir(), "dowl/default.erb")
      if validate_template()
        return true
      end 
      
      @template_file_name = File.join(File.dirname(__FILE__), "default.erb")
      if validate_template()
        return true
      end 

      warn "Could not find template"
      return false
    end
    
  end
end