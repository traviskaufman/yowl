module DOWL

  class Generator
    
    def initialize(schema, template)
      @schema = schema
      if template == nil
        @template = default_template()
      else
        @template = ERB.new(File.read(template))
      end
      if schema.introduction
        @introduction = File.read(schema.introduction)
      end      
    end
    
    def default_template()
      template = File.join(@schema.dir, "dowl/default.erb")
      if File.exists?(template)
        return template
      end
      template = File.join(File.dirname(__FILE__), "default.erb")
      if File.exists?(template)
        return template
      end
      raise "Could not find template: default.erb"
    end
    
    def run()      
      b = binding
      schema = @schema
      introduction = @introduction
      return @template.result(b)               
    end
    
  end  
  
end
