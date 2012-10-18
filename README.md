A simple command-line tool for generating HTML documentation from RDFS/OWL schemas.

This is a fork of the original DOWL project at https://github.com/ldodds/dowl.
This fork adds the following features:

  - It reads a whole directory of .owl files and generates one site for them
  - It generates all kinds of diagrams: Class Diagrams, Individuals Diagrams, Import Diagram
  - It detects more Dublin Core statements

### INSTALLATION

#### Installation on Mac OS X:

  - Download and install MacPorts
  - sudo port install libraptor

NOTE: There are issues with installing libraptor on Mac OS X. It seems that the Ruby RDF library depends on libraptor 1 whereas MacPorts installs libraptor 2.

#### Installation on Ubuntu

```bash
apt-get install ruby
```

#### General

Install all libraries used by DOWL:

```bash
[sudo] gem install ffi rdf rdf-raptor rdf-json rdf-trix sxp sparql ruby-graphviz
```

This version of DOWL is not yet available as a "gem" itself so it needs to be downloaded from Github:


  To install from a source simply do:

```bash
    [sudo] rake install
```

  Both options will give you a new command-line application called dowl.

Usage

  Execute bin/dowl to see usage options.

