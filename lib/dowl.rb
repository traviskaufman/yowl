require 'rubygems'
require 'erb'
require 'rdf'
require 'rdf/ntriples' # Support for N-Triples (.nt)
require 'rdf/raptor'   # Support for RDF/XML (.rdf) and Turtle (.ttl)
require 'rdf/json'     # Support for RDF/JSON (.json)
require 'rdf/trix'     # Support for TriX (.xml)
require 'optparse'
require 'dowl/optionsparser'
require 'dowl/options2'
require 'dowl/util'
require 'dowl/schema'
require 'dowl/class'
require 'dowl/property'
require 'dowl/ontology'
require 'dowl/generator'

module DOWL
      
  class Namespaces

    OWL = RDF::Vocabulary.new("http://www.w3.org/2002/07/owl#")    
    RDFS = RDF::RDFS    
    VS = RDF::Vocabulary.new("http://www.w3.org/2003/06/sw-vocab-status/ns#")    
    DC = RDF::Vocabulary.new("http://purl.org/dc/elements/1.1/")
    DCTERMS = RDF::Vocabulary.new("http://purl.org/dc/terms/")
    FOAF = RDF::Vocabulary.new("http://xmlns.com/foaf/0.1/")
    VANN = RDF::Vocabulary.new("http://purl.org/vocab/vann/")
        
  end

end
