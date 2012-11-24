# Installation on Mac OS X

Unfortunately, its not trivial to get YOWL to run on Mac OS X.

You can either use MacPorts or Brew to install some of the components that YOWL needs.

## MacPorts

You first have to download and install MacPorts: http://www.macports.org/install.php

Then use MacPorts to install GraphViz (which is used to generate the graphics) and wget:

```
sudo port install graphviz wget
```

## Brew

As an alternative to MacPorts, you can install Brew and use that to install Graphviz,
for installation instructions of Brew look here: https://github.com/mxcl/homebrew/wiki/Installation

Once Brew is installed, install Graphviz and wget:

```
sudo brew install graphviz wget
```

## Raptor 1

YOWL depends on the Ruby package "ruby-rdf" which in turn depends on a C library called "raptor".
Unfortunately, MacPorts recently dropped support for the older version of Raptor (version 1) that
is used by ruby-rdf, so MacPorts can only install version 2, which is not compatible with ruby-rdf,
so don't bother to install it.
The only solution (as far as I know) is to build that older version of Raptor 1 from source:

```
mkdir -p ~/Work/build
cd ~/Work/build
wget http://download.librdf.org/source/raptor-1.4.21.tar.gz
tar xvf raptor-1.4.21.tar.gz 
cd raptor-1.4.21
./configure "CPPFLAGS=-I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.7.sdk/usr/include"
make
sudo make install
```

As you can see in the configure line above, the build procedure assumes that you have Xcode installed, where it tries to find "curl/types.h".
If you have this file installed elsewhere then change that location on the configure line. 
One way to find "curl/types.h" is:

```
sudo locate types.h | grep curl
```

Or

```
sudo find /usr /opt /sw /Applications -name 'types.h' | grep curl
```

## Gems

YOWL depends on various "ruby gems" that can be installed as follows:

```
sudo gem install ffi rdf rdf-raptor rdf-json rdf-trix sxp sparql ruby-graphviz
```
