module DOWL

  class Generator
    
    def initialize(schemas, options)
      @schemas = schemas
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
      schemas.each() do |schema|
        introduction = @introduction
        b = binding
        #
        # TODO: Write the output in a file in the target directory
        #
        output_file = File.join(@options.html_output_dir, schema.name + '.html')
        if @options.verbose
          puts "Generating #{output_file}"
        end
        File.open(output_file, 'w') do |file|
          file.write(@template.result(b))
        end
      end
    end
  end  
end
