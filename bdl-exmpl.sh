#!/usr/bin/env bash
# Examples using bdl-lib.sh

# Source bdl-lib.sh
. bdl-lib.sh

# These both output to the default bdl_stdout=1
bdl
bdl "hi"
bdl 1 "hi"

# Output to a file as parameter
echo -n >bdl_out.txt
bdl bdl_out.txt "hi to bdl_out.txt"
cat bdl_out.txt

# Output to a file via bdl_dst
echo -n >bdl_out.txt
bdl_dst=bdl_out.txt
bdl "hi to bdl_out.txt"
cat bdl_out.txt
bdl_dst=

# Output to FD 5 connected to 1 via bdl_stdout
bdl_stdout=5
exec 5>&1
bdl
bdl "hi"
bdl 5 "hi"
exec 1>&5
bdl_stdout=1

# No printing to stdout
echo -n >bdl_out.txt
bdl_stdout=1
bdl_dst=
bdl 0 "not printed"
bdl_stdout=0
bdl
bdl bdl_out.txt "printed to bdl_out.txt"
bdl "not printed"
bdl_stdout=1
cat bdl_out.txt

# This prints a "0" since there is only one parameter
bdl 0
