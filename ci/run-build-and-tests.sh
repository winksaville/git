#!/bin/sh
#
# Build and test Git
#

. ${0%/*}/lib-travisci.sh

ln -sf "$cache_dir/.prove" t/.prove

echo "jobname=$jobname"
if test "$jobname" = "osx-clang" || test "$jobname" = "osx-gcc"; then
	system_profiler SPSoftwareDataType
fi

make --jobs=2
cd t

DEFAULT_TEST_TARGET="./t001*.sh ./t0204*.sh" make
