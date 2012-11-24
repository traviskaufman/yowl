
# YOWL

Yet another OWL documentor. YOWL is a command line utility that can read a number of
RDFS/OWL files, called the repository, and generate a documentation website from it,
with Class Diagrams (as SVG), Individuals Diagrams and Import Diagrams.

It also detects annotations from the following public ontologies:

  - Dublin Core
  - [Term-centric Semantic Web Vocabulary Annotations](http://www.w3.org/2003/06/sw-vocab-status/note)
  - [VANN](http://vocab.org/vann/.html)
  - SKOS
  - FOAF
  
This is a fork of the original DOWL project at https://github.com/ldodds/dowl.

# INSTALLATION

## Installation on Mac OS X:

[Installation on Mac OS X](INSTALL-MACOSX.md)

## Installation on Ubuntu

```bash
apt-get install ruby rake gem
```

## General

Install all libraries used by YOWL:

```bash
[sudo] gem install ffi rdf rdf-raptor rdf-json rdf-trix sxp sparql ruby-graphviz
```

This version of YOWL is not yet available as a "gem" itself so it needs to be downloaded from Github:

```bash
mkdir ~/downloads
cd ~/downloads
wget http://github.com/jgeluk/yowl/tarball/master -O yowl.tar.gz
tar xvf yowl.tar.gz
#
# Remember the name of the root directory of the unpacked tarball
# which looks like jgeluk-yowl-5ba77f5
#
sudo rm -rf /opt/yowl
sudo mv ~/downloads/jgeluk-yowl-5ba77f5 /opt/yowl
cd /opt/yowl
sudo rake install
```

Or get it with git:

```bash
rm -rf /opt/yowl
cd /opt
git clone git@github.com:jgeluk/yowl.git
cd /opt/yowl
sudo rake install
```

# Usage

Execute bin/yowl to see usage options:

```bash
user@host:/opt/yowl# /opt/yowl/bin/yowl 
Output will be generated in this directory: /opt/yowl
Usage: YOWL [<options>]

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
download the prov owl file and run YOWL as follows:

```bash
/opt/yowl/bin/yowl -i /root/downloads/prov/*.owl -o /var/www/prov
```


