A simple command-line tool for generating HTML documentation from RDFS/OWL schemas.

This is a fork of the original DOWL project at https://github.com/ldodds/dowl.
This fork adds the following features:

  - It reads a whole directory of .owl files and generates one site for them
  - It generates all kinds of diagrams: Class Diagrams, Individuals Diagrams, Import Diagram
  - It detects more Dublin Core statements

# INSTALLATION

## Installation on Mac OS X:

[Installation on Mac OS X](INSTALL-MACOSX.md)

## Installation on Ubuntu

```bash
apt-get install ruby rake gem
```

## General

Install all libraries used by DOWL:

```bash
[sudo] gem install ffi rdf rdf-raptor rdf-json rdf-trix sxp sparql ruby-graphviz
```

This version of DOWL is not yet available as a "gem" itself so it needs to be downloaded from Github:

```bash
mkdir ~/downloads
cd ~/downloads
wget http://github.com/jgeluk/dowl/tarball/master -O dowl.tar.gz
tar xvf dowl.tar.gz
#
# Remember the name of the root directory of the unpacked tarball
# which looks like jgeluk-dowl-5ba77f5
#
sudo rm -rf /opt/dowl
sudo mv ~/dowloads/jgeluk-dowl-5ba77f5 /opt/dowl
cd /opt/dowl
sudo rake install
```

Or get it with git:

```bash
rm -rf /opt/dowl
cd /opt
git clone git@github.com:jgeluk/dowl.git
cd /opt/dowl
sudo rake install
```

# Usage

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


