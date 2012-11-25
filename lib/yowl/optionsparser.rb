module YOWL
  
  class OptionsParser
  
    def self.parse(args_)
      
      options = Options.new
  
      opts = OptionParser.new do |opts|
        #
        # Set a banner, displayed at the top of the help screen.
        #
        opts.banner = "Usage: YOWL [<options>]"
  
        opts.separator ""
        opts.separator "Specific options:"
  
        opts.on('-i', '--ontology FILES', String, 'Read input FILES') do |ontology|
          options.ontology_file_names << ontology
          if args_.size > 0
            for index in 0..(args_.size - 1)
              arg = args_[index]
              if arg[0,1] == '-'
                break
              end
              options.ontology_file_names << arg
            end
          end
        end
   
        opts.on('-o', '--output DIR', 'Write HTML output to DIR') do |dir|
          options.output_dir = dir
        end

        opts.on('-t', '--template DIR', 'Use ERB templates in DIR') do |dir|
          options.template_dir = dir
        end
        
        opts.on('--no-vann', 'Skip looking for vann:preferedNamespacePrefix') do |value|
          options.noVann = true
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

        opts.on_tail("-q", "--quiet", "Suppress most logging") do
          options.quiet = true
        end
        
      end
  
      opts.parse!(args_)
      
      if ! options.validate()
        puts opts
        return nil
      end
      return options
    end  # parse()
  end  # class OptionParser
end