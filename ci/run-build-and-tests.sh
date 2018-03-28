#!/bin/sh
#
# Build and test Git
#

. ${0%/*}/lib-travisci.sh

ln -s "$cache_dir/.prove" t/.prove

make --jobs=2
make --quiet test
if test "$jobname" = "linux-gcc"
then
	GIT_TEST_SPLIT_INDEX=YesPlease make --quiet test
fi

#check_unignored_build_artifacts

#save_good_tree

# Test 4015
cd t
./t4015-diff-whitespace.sh -d -i -v

set -x
cd trash\ directory.t4015-diff-whitespace/
git log --oneline
ls -al
cat bananas/recipe
cat fruit.t
cat actual
cat decoded_actual
cat expect
