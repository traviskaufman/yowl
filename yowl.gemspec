# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "yowl/version"

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.summary = %q{OWL visualization and documentation generator}
  s.description = <<-EOF
    Yet another OWL documentor. YOWL is a command line utility that can read a number of RDFS/OWL files, 
    called the repository, and generate a documentation website from it, with visualisations like
    Class Diagrams (as SVG), Individuals Diagrams and Import Diagrams.
  EOF
  s.name = %q{yowl}
  s.version = YOWL::VERSION
  s.required_ruby_version = ">= 1.8.7"    
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.md", "INSTALL-MACOSX.md", "CHANGES"]
  s.rdoc_options = ['--quiet', '--title', 'yowl reference', '--main', 'README.md']
  s.authors = ['Leigh Dodds', 'Jacobus Geluk']
  s.email = ['leigh.dodds@talis.com', 'jacobus.geluk@gmail.com']
  s.homepage = 'http://github.com/jgeluk/yowl'
  s.files = %w(README.md INSTALL-MACOSX.md Rakefile CHANGES) + Dir.glob("{bin,test,examples,lib}/**/*")
  s.require_path = "lib" 
  s.bindir = "bin"
  s.executables = ["yowl"]
  s.test_file = "test/test_yowl.rb"
  s.add_dependency("ffi", ">= 1.1.5")
  s.add_dependency("json", ">= 1.7.5")
  s.add_dependency("rdf", ">= 0.3.8")
  s.add_dependency("rdf-raptor", ">= 0.4.2")
  s.add_dependency("rdf-json", ">= 0.3.0")
  s.add_dependency("rdf-trix", ">= 0.3.0")
  s.add_dependency("rdf-xsd", ">= 0.3.8")
  s.add_dependency("sxp", ">= 0.0.14")
  s.add_dependency("sparql", ">= 0.3.1")
  s.add_dependency("ruby-graphviz", ">= 1.0.8")
  s.rubyforge_project = 'nowarning'
end
