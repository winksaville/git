#!/bin/sh
#
# Build and test Git
#

. ${0%/*}/lib-travisci.sh

ln -sf "$cache_dir/.prove" t/.prove

make --jobs=2
cd t

DEFAULT_TEST_TARGET="./t001*.sh ./t0204*.sh" make
