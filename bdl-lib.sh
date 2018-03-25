# ##################################################################
# Bash Debug logger scriplet, source into your script to use.
#
# Write debug info with file name and line number.
#
# If the number of parameters == 0 then just the file
# name and line number are printed to the destination.
#
# If the number of parameters == 1 then the file
# name and line number are printed followed by a space
# and then the parameter.
# 
# If number of parameters > 1 then the first parameter
# is the destination and the other parameters are written
# to the destination.
#
# The destination can be the first parameter to bdl
# or bdl_stdout or bdl_dst. If the destination is empty
# then the data is written to bdl_stdout unless bdl_stdout
# is empty or 0 then no data is written. Also, if the
# destination is 0 no data is written.
#
# Examples:
#$ cat -n bdl-exmpl.sh 
#     1	#!/usr/bin/env bash
#     2	# Examples using bdl-lib.sh
#     3	
#     4	# Source bdl-lib.sh
#     5	. bdl-lib.sh
#     6	
#     7	# These both output to the default bdl_stdout=1
#     8	bdl
#     9	bdl "hi"
#    10	bdl 1 "hi"
#    11	
#    12	# Output to a file as parameter
#    13	echo -n >bdl_out.txt
#    14	bdl bdl_out.txt "hi to bdl_out.txt"
#    15	cat bdl_out.txt
#    16	
#    17	# Output to a file via bdl_dst
#    18	echo -n >bdl_out.txt
#    19	bdl_dst=bdl_out.txt
#    20	bdl "hi to bdl_out.txt"
#    21	cat bdl_out.txt
#    22	bdl_dst=
#    23	
#    24	# Output to FD 5 connected to 1 via bdl_stdout
#    25	bdl_stdout=5
#    26	exec 5>&1
#    27	bdl
#    28	bdl "hi"
#    29	bdl 5 "hi"
#    30	exec 1>&5
#    31	bdl_stdout=1
#    32	
#    33	# No printing to stdout
#    34	echo -n >bdl_out.txt
#    35	bdl_stdout=1
#    36	bdl_dst=
#    37	bdl 0 "not printed"
#    38	bdl_stdout=0
#    39	bdl
#    40	bdl bdl_out.txt "printed to bdl_out.txt"
#    41	bdl "not printed"
#    42	bdl_stdout=1
#    43	cat bdl_out.txt
#    44	
#    45	# This prints a "0" since there is only one parameter
#    46	bdl 0
#
#
# This is the output of bdl-exmpl.sh
#
#  $ /bin/bash ./bdl-exmpl.sh
#  bdl-exmpl.sh:8:
#  bdl-exmpl.sh:9: hi
#  bdl-exmpl.sh:10: hi
#  bdl-exmpl.sh:14: hi to bdl_out.txt
#  bdl-exmpl.sh:20: hi to bdl_out.txt
#  bdl-exmpl.sh:27:
#  bdl-exmpl.sh:28: hi
#  bdl-exmpl.sh:29: hi
#  bdl-exmpl.sh:40: printed to bdl_out.txt
#  bdl-exmpl.sh:46: 0
# ##################################################################

BDL_LOADED=t

# Prompt waitng for a return, q will exit
bdl_pause () {
	read -p "Line ${BASH_LINENO}: $@" bdl_pause_v_
	[[ "$bdl_pause_v_" == "q" ]] && exit 1
}

# Initialize bdl variables if user didn't
[[ "$bdl_dst" == "" ]] && bdl_dst=
[[ "$bdl_stdout" == "" ]] && bdl_stdout=1
[[ "$bdl_call_depth" == "" ]] && bdl_call_depth=0
[[ "$bdl_call_stack_view" == "" ]] && bdl_call_stack_view=f

# Initialize priviate bdl variables
_bdl_call_lineno_offset_array=()
_bdl_call_lineno_offset_array_idx=0
_bdl_call_save=()
_bdl_call_save_idx=0

# Push bdl state and initialize call meta data.
#
# $1 is value for bdl_call_depth
# $2 Optional text of a script with where bdl calls
#    will be found and used to compute lineno info.
bdl_push () {
	# Push the bdl data
	_bdl_call_save[$_bdl_call_save_idx]="bdl_dst=$bdl_dst; \
bdl_stdout=$bdl_stdout; \
bdl_call_depth=$bdl_call_depth; \
bdl_call_stack_view=$bdl_call_stack_view; \
_bdl_call_lineno_offset_array=(${_bdl_call_lineno_offset_array[*]}); \
_bdl_call_lineno_offset_array_idx=$_bdl_call_lineno_offset_array_idx"
	_bdl_call_save_idx=$((_bdl_call_save_idx+1))

	# Set meta data to fudge line numbers when bdl is used in tests.
	bdl_call_depth=$1
	shift
	_bdl_call_lineno_offset_array_idx=0
	_bdl_call_lineno_offset_array=()

	if test "$1" != ""
	then
		# Read the script and find lines that begin with "bdl "
		# and compute their offsets and saving them in an array
		# that bdl will use to compute compute the lineno.
		IFS=$'\n' read -d '' -r -a test_run_script_array <<< "$@"
		for i in "${!test_run_script_array[@]}"; do
			ln=${test_run_script_array[$i]}
			tln="$(sed -e 's/^[[:space:]]*//' <<<$ln)"
			if [[ "$tln" =~ ^bdl\  ]]
			then
				_bdl_call_lineno_offset_array+=$((i+1))
			fi
		done
	fi
}

# Pop a previously save state.
bdl_pop () {
	_bdl_call_save_idx=$((_bdl_call_save_idx-1))
	eval "${_bdl_call_save[$_bdl_call_save_idx]}"
}

# Write debug info with no source or line number
bdl_nsl () {
	if (( $# > 1 )); then
		bdl_nsl_v_=$1
		shift
	else
		bdl_nsl_v_=$bdl_dst
	fi
	[[ "$bdl_nsl_v_" == "" ]] && bdl_nsl_v_=$bdl_stdout
	if [[ "$bdl_nsl_v_" != "" && "$@" != "" ]]; then
		if [[ $bdl_nsl_v_ =~ ^[0-9] ]]; then
			# There's probably a better way, but this "works":
			case $bdl_nsl_v_ in
				1) echo "$@" 1>&1 ;;
				2) echo "$@" 1>&2 ;;
				3) echo "$@" 1>&3 ;;
				4) echo "$@" 1>&4 ;;
				5) echo "$@" 1>&5 ;;
				6) echo "$@" 1>&6 ;;
				7) echo "$@" 1>&7 ;;
				8) echo "$@" 1>&8 ;;
				9) echo "$@" 1>&9 ;;
				*) : ;; # 0 and all other characters are nop's
			esac
		else
			echo "$@" >> $bdl_nsl_v_
		fi
	fi
	return 0
}

# Write debug info with file name and line number.
bdl () {
	#View the call stack
	if test "$bdl_call_stack_view" != "f"
	then
		for i in "${!BASH_SOURCE[@]}"; do
			(( $i == 0 )) && ln=${LINENO} || ln=${BASH_LINENO[${i}-1]}
			bdl_nsl "[$i] ${BASH_SOURCE[$i]##*/}:${FUNCNAME[$i]}:${ln}"
		done
	fi

	# The ${@:+ } only adds a space if $@ isn't empty.
	# This is done because We allow the call to bdl to
	# have no parameters and bdl then just prints the
       	# file name and line number which can be useful
	# to know a line was processed but there is no need
	# to print any other data.
	bdl_ln=${BASH_LINENO[${bdl_call_depth}]}
	if (( ${_bdl_call_lineno_offset_array_idx} < ${#_bdl_call_lineno_offset_array[@]} ))
	then
		bdl_offset=${_bdl_call_lineno_offset_array[$_bdl_call_lineno_offset_array_idx]}
		bdl_ln=$((bdl_ln+bdl_offset))
		_bdl_call_lineno_offset_array_idx=$((_bdl_call_lineno_offset_array_idx+1))
	fi
	if (( $# <= 1 )); then
		bdl_nsl $bdl_dst "${BASH_SOURCE[${bdl_call_depth}+1]##*/}:${bdl_ln}:${@:+ }$@"
	else
		v_=$1
		shift
		bdl_nsl $v_ "${BASH_SOURCE[${bdl_call_depth}+1]##*/}:${bdl_ln}:${@:+ }$@"
	fi
	return 0
}
