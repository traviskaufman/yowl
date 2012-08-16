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
  
        opts.on('-t', '--template FILE', 'Use ERB template FILE') do |template|
          options.template_file_name = template
        end

        opts.on('--introduction FILE', 'Use HTML file as introduction') do |htmlfile|
          options.introduction_file_name = htmlfile
        end
   
        opts.separator ""
        opts.separator "Common options:"
  
        # No argument, shows at tail.  This will print an options summary.
        # Try it and see!
        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end
  
        # Another typical switch to print the version.
        opts.on_tail("--version", "Show version") do
          puts OptionParser::Version.join('.')
          exit
        end
        
      end
  
      opts.parse!(args)
      
      if ! options.validate()
        exit
      end
      return options
    end  # parse()
  end  # class OptionParser
end