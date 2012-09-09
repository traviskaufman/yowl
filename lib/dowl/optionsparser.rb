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
  
        opts.on('-i', '--ontology FILES', String, 'Read input FILES') do |ontology|
          options.ontology_file_names << ontology
          index = 0
          while ARGV[index][0,1] != "-"
            options.ontology_file_names << ARGV[index]
            index += 1
          end
        end
   
        opts.on('-o', '--output DIR', 'Write HTML output to DIR') do |dir|
          options.output_dir = dir
        end

        opts.on('-t', '--template DIR', 'Use ERB templates in DIR') do |dir|
          options.template_dir = dir
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
          options.verbose = true
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