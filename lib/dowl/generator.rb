module DOWL

  class Generator
    
    def initialize(schema, options)
      @schema = schema
      @options = options
      @template = ERB.new(options.template.read)
      template_file.close() # Do this more safely. We might need to keep it open to read other info from it.
      if options.introduction != nil
        @introduction = options.introduction.read()
        options.introduction.close()
      end      
    end
    
    def run()      
      b = binding
      schema = @schema
      introduction = @introduction
      #
      # TODO: Write the output in a file in the target directory
      #
      output_file = File.join(@options.html_output_dir, @schema.name + '.html')
      puts "Generating #{output_file}"
      File.open(output_file, 'w') { |file|
        file.write(@template.result(b))
      }
    end
    
  end  
  
end
