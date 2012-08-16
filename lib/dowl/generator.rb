module DOWL

  class Generator
    
    def initialize(schema, options)
      @schema = schema
      @options = options
      begin
        @template = ERB.new(options.template.read)
      ensure
        options.template.close()
      end
      if options.introduction != nil
        begin
          @introduction = options.introduction.read()
        ensure
          options.introduction.close()
        end
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
