module DOWL
  class Options
    
    attr_accessor :ontology_file_names
    attr_accessor :html_output_dir
    attr_accessor :template_file_name
    
    def initialize ()
      @ontology_file_names = []
      @html_output_dir = Dir.pwd()
      @template_file_name = "default.erb"
    end
    
    def validate()
      return true
    end
  end
end