#!/bin/sh
#
# Build and test Git
#

. ${0%/*}/lib-travisci.sh

ln -s "$cache_dir/.prove" t/.prove

make --jobs=2
cd t
prove --timer --jobs 2 ./t001*.sh ./t0050*.sh ./t0204*.sh ./t9822*.sh
#./t0050-filesystem.sh
#./t0204-gettext-reencode-sanity.sh
#./t9822-git-p4-path-encoding.sh

rm t/.prove
