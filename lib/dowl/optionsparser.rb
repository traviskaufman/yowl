module DOWL
  
  class OptionsParser
  
    def self.parse(args)
    
      options = Options.new
  
      opts = OptionParser.new do |opts|
        #
        # Set a banner, displayed at the top of the help screen.
        #
        opts.banner = "Usage: " + PROGRAM + " [<options>] [<template>]"
  
        opts.separator ""
        opts.separator "Specific options:"
  
        opts.on('-i', '--ontology FILE', 'Read FILE') do |ontology|
          options.ontologies << ontology
        end
   
        opts.on( '-o', '--htmldir DIR', 'Write HTML output to DIR' ) do |dir|
          options.htmldir = dir
        end
  
        opts.on( '-o', '--template FILE', 'Use ERB template FILE' ) do |template|
          options.template = template
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