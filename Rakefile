require 'rake'
require 'rubygems'
require 'rubygems/package_task'
require 'rdoc/task'
require 'rake/testtask'
require 'rake/clean'

NAME = "yowl"
VER = "0.4.pre"

RDOC_OPTS = ['--quiet', '--title', 'yowl reference', '--main', 'README.md']

PKG_FILES = %w(README.md INSTALL-MACOSX.md Rakefile CHANGES) + 
  Dir.glob("{bin,test,examples,lib}/**/*")

CLEAN.include ['*.gem', 'pkg']

SPEC = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.summary = 'OWL visualization and documentation generator'
  s.description = <<-EOF
    Yet another OWL documentor. YOWL is a command line utility that can read a number of RDFS/OWL files, 
    called the repository, and generate a documentation website from it, with visualisations like
    Class Diagrams (as SVG), Individuals Diagrams and Import Diagrams.
  EOF
  s.name = NAME
  s.version = VER
  s.required_ruby_version = ">= 1.8.7"    
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.md", "INSTALL-MACOSX.md", "CHANGES"]
  s.rdoc_options = RDOC_OPTS
  s.authors = ['Leigh Dodds', 'Jacobus Geluk']
  s.email = ['leigh.dodds@talis.com', 'jacobus.geluk@gmail.com']
  s.homepage = 'http://github.com/jgeluk/yowl'
  s.files = PKG_FILES
  s.require_path = "lib" 
  s.bindir = "bin"
  s.executables = ["yowl"]
  s.test_file = "test/test_yowl.rb"
  s.add_dependency("rdf-raptor", ">= 0.4.0")
  s.add_dependency("ffi", ">= 1.1.5")
  s.add_dependency("rdf", ">= 0.3.8")
  s.add_dependency("rdf-raptor", ">= 0.4.2")
  s.add_dependency("rdf-json", ">= 0.3.0")
  s.add_dependency("rdf-trix", ">= 0.3.0")
  s.add_dependency("sxp", ">= 0.0.14")
  s.add_dependency("sparql", ">= 0.3.1")
  s.add_dependency("ruby-graphviz", ">= 1.0.8")
  s.rubyforge_project = 'nowarning'
end
      
Gem::PackageTask.new(SPEC) do |pkg|
    pkg.need_tar = true
end

RDoc::Task.new do |rdoc|
    rdoc.rdoc_dir = 'doc/rdoc'
    rdoc.options += RDOC_OPTS
    rdoc.rdoc_files.include("README.md", "INSTALL-MACOSX.md", "CHANGES", "lib/**/*.rb")
    rdoc.main = "README.md"
end

Rake::TestTask.new do |test|
  test.verbose = true
end

desc "Install from a locally built copy of the gem"
task :install do
  sh %{rake package}
  sh %{sudo gem install pkg/#{NAME}-#{VER}}
end

desc "Uninstall the gem"
task :uninstall => [:clean] do
  sh %{sudo gem uninstall #{NAME}}
end
