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
      if ! validate_template()
        return false
      end
      return true
    end
    
    def validate_template()
      
      if File.exists?(@template_file_name)
        @template = new File(@template_file_name)
        return true
      end
      
      @template_file_name = File.join(@schema.dir, "dowl/default.erb")
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