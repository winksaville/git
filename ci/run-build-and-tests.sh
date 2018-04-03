#!/bin/sh
#
# Build and test Git
#

. ${0%/*}/lib-travisci.sh

ln -s "$cache_dir/.prove" t/.prove

make --jobs=2
cd t
./t0050-filesystem.sh
./t0204-gettext-reencode-sanity.sh
./t9822-git-p4-path-encoding.sh
