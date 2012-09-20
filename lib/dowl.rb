require 'rubygems'
require 'erb'
require 'rdf'
require 'rdf/ntriples' # Support for N-Triples (.nt)
require 'rdf/raptor'   # Support for RDF/XML (.rdf) and Turtle (.ttl)
require 'rdf/json'     # Support for RDF/JSON (.json)
require 'rdf/trix'     # Support for TriX (.xml)
require 'rdf/raptor'
require 'sparql'
require 'graphviz'
require 'optparse'
require 'dowl/optionsparser'
require 'dowl/options'
require 'dowl/util'
require 'dowl/schema'
require 'dowl/class'
require 'dowl/association'
require 'dowl/individual_association'
require 'dowl/individual'
require 'dowl/property'
require 'dowl/ontology'
require 'dowl/import'
require 'dowl/person'
require 'dowl/generator'
require 'dowl/repository'

module DOWL
      
  class Namespaces

    OWL = RDF::Vocabulary.new("http://www.w3.org/2002/07/owl#")    
    RDFS = RDF::RDFS    
    VS = RDF::Vocabulary.new("http://www.w3.org/2003/06/sw-vocab-status/ns#")    
    DC = RDF::Vocabulary.new("http://purl.org/dc/elements/1.1/")
    DCTERMS = RDF::Vocabulary.new("http://purl.org/dc/terms/")
    FOAF = RDF::Vocabulary.new("http://xmlns.com/foaf/0.1/")
    VANN = RDF::Vocabulary.new("http://purl.org/vocab/vann/")
    SKOS = RDF::Vocabulary.new("http://www.w3.org/2004/02/skos/core#")
        
  end

end
