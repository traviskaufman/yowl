# YOWL: Yet another OWL documentor

YOWL is a command line utility that can read a number of
RDFS/OWL files, called the repository, and generate a documentation website from it,
with visualisations like Class Diagrams (as SVG), Individuals Diagrams and Import Diagrams.

It also detects annotations from the following public ontologies:

  - Dublin Core
  - [Term-centric Semantic Web Vocabulary Annotations](http://www.w3.org/2003/06/sw-vocab-status/note)
  - [VANN](http://vocab.org/vann/.html)
  - SKOS
  - FOAF
  
This is a fork of the original DOWL project at https://github.com/ldodds/dowl.

## INSTALLATION

### Install WGET, GraphViz, libraptor1:

#### OS X
You can do this using [macports](http://www.macports.org/install.php) or [homebrew](http://mxcl.github.com/homebrew/).

Macports:
```sh
$ sudo port install wget graphviz
```

Homebrew:
```sh
$ sudo brew install wget graphviz
```

Unfortunately, there is no clean way (as far as we know) to install libraptor1 via a package manager on OS X. Therefore we wrote a small shell script, `install-raptor.sh` to do it for you. 
```sh
$ sudo curl -k https://raw.github.com/modelfabric/yowl/master/install-raptor.sh | bash
```

#### Ubuntu

```bash
$ sudo apt-get install wget graphviz libraptor1-dev rubygems
```

### Amazon Linux

```bash
$ sudo yum -y install graphviz libraptor1-dev rubygems ruby-devel ffi-devel make gcc
```

And then install Raptor 1.4.21 (which is required by rdf-raptor) like this:
```bash
$ sudo yum -y install http://download.librdf.org/binaries/redhat/fc12/raptor-1.4.21-1.fc12.x86_64.rpm
$ sudo yum -y install http://download.librdf.org/binaries/redhat/fc12/raptor-devel-1.4.21-1.fc12.x86_64.rpm
```

### Install via RubyGems
```sh
$ gem install yowl
```

### Bleeding Edge/Development Builds
```sh
$ git clone https://github.com/modelfabric/yowl.git
$ cd yowl/
$ gem build yowl.gemspec
$ gem install yowl
```

## Usage

Execute `yowl -h` to see usage options:

```bash
$ yowl
yowl [VERSION_WILL_APPEAR_HERE]

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
    -q, --quiet                      Suppress most logging
```

For example, to generate a site for the PROV ontology,
download the prov owl file and run YOWL as follows:

```bash
$ yowl -i /path/to/prov/*.owl -o /var/www/prov
```

## License (MIT)
The MIT License (MIT)

Copyright (c) 2013 ModelFabric

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
