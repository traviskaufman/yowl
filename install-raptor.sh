###
# Installs Raptor v1.4.21 from source (on OS X)
###
wd="$(mktemp -dt raptor-build)"
raptor_gz="$wd/raptor.tar.gz"

mkdir -p $wd
echo "Downloading raptor-1.4.21 to $wd..."
curl --compressed http://download.librdf.org/source/raptor-1.4.21.tar.gz > $raptor_gz
tar xf $raptor_gz -C $wd
echo "Building library..."
(cd $wd/raptor-1.4.21; ./configure && make && make install) || (cat $wd/raptor-1.4.21/config.log > raptorbuild_error.log && echo "Install failed. See raptorbuild_error.log for more details.")
rm -rf $wd
