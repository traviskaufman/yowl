require 'rake'
require 'rdoc/task'
require 'rake/testtask'
require 'rake/clean'
if RUBY_VERSION < "1.9.2"
  require "lib/yowl/version"
else
  require_relative "lib/yowl/version"
end

RDOC_OPTS = ['--quiet', '--title', '#{YOWL::NAME} reference', '--main', 'README.md']

CLEAN.include ['*.gem', 'pkg']

RDoc::Task.new do |rdoc|
    rdoc.rdoc_dir = 'doc/rdoc'
    rdoc.options += RDOC_OPTS
    rdoc.rdoc_files.include("README.md", "INSTALL-MACOSX.md", "CHANGES", "lib/**/*.rb")
    rdoc.main = "README.md"
end

Rake::TestTask.new do |test|
  test.verbose = true
end

