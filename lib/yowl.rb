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
require 'optparse/version'
require 'yowl/version'
require 'yowl/optionsparser'
require 'yowl/options'
require 'yowl/util'
require 'yowl/schema'
require 'yowl/class'
require 'yowl/association'
require 'yowl/individual_association'
require 'yowl/individual'
require 'yowl/property'
require 'yowl/ontology'
require 'yowl/import'
require 'yowl/person'
require 'yowl/generator'
require 'yowl/repository'

module YOWL
      
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
