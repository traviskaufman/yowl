module DOWL
  
  class OptionsParser
  
    def self.parse(args)
    
      options = Options.new
  
      opts = OptionParser.new do |opts|
        #
        # Set a banner, displayed at the top of the help screen.
        #
        opts.banner = "Usage: " + PROGRAM + " [<options>]"
  
        opts.separator ""
        opts.separator "Specific options:"
  
        opts.on('-i', '--ontology FILE', 'Read FILE') do |ontology|
          options.ontology_file_names << ontology
        end
   
        opts.on('-o', '--htmldir DIR', 'Write HTML output to DIR') do |dir|
          options.html_output_dir = dir
        end

        opts.on('--index FILE', 'Generate an index.html file named FILE') do |index|
          options.index_file_name = index
        end
  
        opts.on('-t', '--template FILE', 'Use ERB template FILE') do |template|
          options.ontology_template_file_name = template
        end

        opts.on('--introduction FILE', 'Use HTML file as introduction') do |htmlfile|
          options.introduction_file_name = htmlfile
        end
   
        opts.separator ""
        opts.separator "Common options:"
  
        opts.on_tail("-?", "-h", "--help", "Show this message") do
          puts opts
          return nil
        end
  
        opts.on_tail("-V", "--version", "Show version") do
          puts OptionParser::Version.join('.')
          exit
        end

        opts.on_tail("-v", "--verbose", "Show verbose logging") do
          options.verbose? = true
        end
        
      end
  
      opts.parse!(args)
      
      if ! options.validate()
        puts opts
        return nil
      end
      return options
    end  # parse()
  end  # class OptionParser
end