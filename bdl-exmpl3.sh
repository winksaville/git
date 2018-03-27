#!/usr/bin/env bash
. bdl-lib.sh

# Output to STDOUT
bdl_nsl 1 "hi there"

# Map 5 to STDOUT
exec 5>&1
bdl 5 "yo dude"

# Output to a file
bdl bdl_out.txt "good bye!"
cat bdl_out.txt
rm bdl_out.txt
