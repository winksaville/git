#!/bin/sh
# Debug logging library

# Prompt waitng for a return, q will exit
dbg_pause () {
	read -p "Line ${BASH_LINENO}: $@" dbg_pause_v_
	[[ "$dbg_pause_v_" == "q" ]] && exit 1
}

# Set the dbg_stdout to 1 if its not set
[[ "$dbg_stdout" == "" ]] && dbg_stdout=1
[[ "$dbg_caller_depth" == "" ]] && dbg_caller_depth=0

# Write debug info with no source or line number
#
# If the number of parameters == 0 nothing is printed.
#
# If the number of parameters == 1 then that data is
# printed to the destination defined by dbg_dst or
# dbg_stdout.
# 
# If number of parameters > 1 then the first parameter
# is the destination and the other parameters are written
# to the destination.
#
# If the destination is empty then the data is written
# to dbg_stdout unless dbg_stdout is empty or 0 then no
# data is written. Also, if the destination is 0 no data
# is written.
dbg_nsl () {
	#echo "dbg_ns #=$# @'$@'"
	if (( $# > 1 )); then
		wnsl_v_=$1
		shift
	else
		wnsl_v_=$dbg_dst
	fi
	[[ "$wnsl_v_" == "" ]] && wnsl_v_=$dbg_stdout
	if [[ "$wnsl_v_" != "" && "$@" != "" ]]; then
		if [[ $wnsl_v_ =~ ^[0-9] ]]; then
			# I couldn't figure out how to get something like
			# the following to work:
			#  [[ $dbg_fno_v_ =~ ^[1-9] ]] echo "${wd_header_} $@" 1>&${dbg_fno_v_}
			case $wnsl_v_ in
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
			echo "$@" >> $wnsl_v_
		fi
	fi
	return 0
}

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
# If the destination is empty then the data is written
# to dbg_stdout unless dbg_stdout is empty or 0 then no
# data is written. Also, if the destination is 0 no data
# is written.
dbg () {
	##View the call stack
	#for ((i=0; i<=${#BASH_SOURCE[@]}-1; i++)); do
	#	(( $i == 0 )) && ln=${LINENO} || ln=${BASH_LINENO[${i}-1]}
	#	echo "[$i] ${BASH_SOURCE[$i]##*/}:${FUNCNAME[$i]}:${ln}" >> dbg.txt
	#done

	# The ${@:+ } only adds a space if $@ isn't empty.
	# This is done because We allow the call to dbg to
	# have no parameters and dbg then just prints the
       	# file name and line number which can be useful
	# to know a line was processed but there is no need
	# to print any other data.
	if (( $# <= 1 )); then
		dbg_nsl $dbg_dst "${BASH_SOURCE[${dbg_caller_depth}+1]##*/}:${BASH_LINENO[${dbg_caller_depth}+0]}:${@:+ }$@"
	else
		v_=$1
		shift
		dbg_nsl $v_ "${BASH_SOURCE[1]##*/}:${BASH_LINENO[0]}:${@:+ }$@"
	fi
	return 0
}
