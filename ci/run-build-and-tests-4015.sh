#!/bin/sh

make --jobs=2
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
