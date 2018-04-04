#!/bin/sh
#
# Build and test Git
#

. ${0%/*}/lib-travisci.sh

ln -sf "$cache_dir/.prove" t/.prove

command -v lsb_release >/dev/null 2>&1 && lsb_release -v
command -v uname >/dev/null 2>&1 && uname -a

echo "jobname=$jobname"
case "$jobname" in
	"osx-clang"|"osx-gcc") system_profiler SPSoftwareDataType ;;
esac


make --jobs=2
cd t

DEFAULT_TEST_TARGET="./t001*.sh ./t0204*.sh" make
