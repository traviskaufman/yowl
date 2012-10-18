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

```bash
rm -rf /opt/dowl
cd /opt
git clone git@github.com:jgeluk/dowl.git
cd /opt/dowl
sudo rake install
```

### Usage

Execute bin/dowl to see usage options:

```bash
user@host:/opt/dowl# /opt/dowl/bin/dowl 
Output will be generated in this directory: /opt/dowl
Usage: dowl [<options>]

Specific options:
    -i, --ontology FILES             Read input FILES
    -o, --output DIR                 Write HTML output to DIR
    -t, --template DIR               Use ERB templates in DIR
        --no-vann                    Skip looking for vann:preferedNamespacePrefix

Common options:
    -?, -h, --help                   Show this message
    -V, --version                    Show version
    -v, --verbose                    Show verbose logging
```

For example, to generate a site for the PROV ontology,
download the prov owl file and run DOWL as follows:

```bash
/opt/dowl/bin/dowl -i /root/downloads/prov/*.owl -o /var/www/prov
```


