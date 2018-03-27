#!/usr/bin/env bash
. bdl-lib.sh

# Set defaults with bdl_dst taking presedence
bdl_dst=bdl_dst_out.txt
bdl_stdout=5

bdl_nsl "printed by bdl_nsl to bdl_dst_out.txt"
bdl "printed by bdl to bdl_dst_out.txt"

# But the parameter the ultimate presedence
bdl bdl_out.txt "good bye to bdl_out.txt"

cat bdl_dst_out.txt
cat bdl_out.txt

rm bdl_dst_out.txt
rm bdl_out.txt

# Now clear bdl_dst and bdl_stdout takes presedence
# but parameters take presedence
bdl_dst=
exec 5>&1

bdl_nsl "monkeys via 5"
bdl 1 "horses via 1"
bdl bdl_out.txt "orcas to bdl_out.txt"

cat bdl_out.txt
rm bdl_out.txt
