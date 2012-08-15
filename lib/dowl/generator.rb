module DOWL

  class Generator
    
    def initialize(schema, template_file, dir)
      @schema = schema
      @template = ERB.new(File.read(template_file))
      @dir = dir
      if schema.introduction
        @introduction = File.read(schema.introduction)
      end      
    end
    
    def run()      
      b = binding
      schema = @schema
      introduction = @introduction
      #
      # TODO: Write the output in a file in the target directory
      #
      file = @template.result(b)
      puts file
    end
    
  end  
  
end
