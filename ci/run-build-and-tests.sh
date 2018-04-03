#!/bin/sh
#
# Build and test Git
#

. ${0%/*}/lib-travisci.sh

ln -s "$cache_dir/.prove" t/.prove

make --jobs=2
cd t
prove --timer --jobs 2 ./t001*.sh ./t0050*.sh ./t0204*.sh ./t9822*.sh
