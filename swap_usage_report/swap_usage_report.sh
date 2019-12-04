#!/bin/bash

    # find-out-what-is-using-your-swap.sh
    # -- Get current swap usage for all running processes
    # --
    # -- rev.0.4, 2019-12-03, Ales Zeleny       - avoid using temp files, add IEC size output, add usage,
    # --                                          add quiet and print size in Bytes option for scripting usage
    # --     Based on script found on serveral places, like https://gist.github.com/samqiu/5954487 ,
    # --     https://config9.com/linux/how-to-find-out-which-processes-are-using-swap-space-in-linux/ and others...
    # -- rev.0.3, 2012-09-03, Jan Smid          - alignment and intendation, sorting
    # -- rev.0.2, 2012-08-09, Mikko Rantalainen - pipe the output to "sort -nk3" to get sorted output
    # -- rev.0.1, 2011-05-27, Erik Ljungstrom   - initial version


# Set initial defalt values
ME=`basename $0`
SORT_KEY=1 # default sort by size
SORT_REVERSE="" # default ascending sort
SORT_NUMERIC="-n" # default alphabetic sort, because default sort by used swap space
OPT_QUIET=0
OPT_PRINT_BYTES=0
SUM=0; # sum swap usage per process
OVERALL=0; # sum swap space used

#
# usage()
#
# Print script usage
#
usage() {
	cat <<-EOF
	Usage: List swap space usage by processes
	$ME [-h|--help] [-p|sort-pid] [-s|--sort-size] [-n|--sort-name] [ -r|--reverse]
	B | size-in-bytes	print swap used space in Bytes
	h | help		print this usage help
	n | sort-name		Sort processes by name
	p | sort-pid		Sort process using swap ordered by PID
	q | quiet		Print only process rows (no header, no summary)
	r | reverse		Reverse sort
	s | sort-size		Sort processes by swap space used space (default)
	EOF
}

#
# getProcsSwapUsage()
#
# Prints SWAP_USED_KB PID PROCES_NAME
# for all processes using SWAP space
#
getProcsSwapUsage() {
	for DIR in `find /proc/ -maxdepth 1 -type d -regex "^/proc/[0-9]+"`; do
	    PID=`echo $DIR | cut -d / -f 3`
	    PROGNAME=`ps -p $PID -o comm --no-headers`

	    for SWAP in `grep Swap $DIR/smaps 2>/dev/null| awk '{ print $2 }'`
	    do
		let SUM=$SUM+$SWAP
	    done

	    if (( $SUM > 0 )); then
		echo -e "${SUM}\t${PID}\t${PROGNAME}"
	    fi
	    SUM=0
	done
}

#
# getPIDFmt()
#
# Print formatted PID
#
getPIDFmt() {
	numfmt --padding=6 $1
}

#
# getSizeFmt() <size_in_kb>
#
# Print formatted size_in_kb
#
getSizeFmt() {
	local kb=$1
	if [ $OPT_PRINT_BYTES -eq 0 ]; then
		# IEC formatting allow smaller padding
		numfmt --to=iec-i --suffix=B --padding=7 $((kb*1024))
	else
		# larger padding for printing size in Bytes
		numfmt --padding=12 $((kb*1024))
	fi
}


#
# printHeader()
#
# print header based on sort key
#
printHeader() {
	echo "========================================"
	if [ $OPT_PRINT_BYTES = 1 ]; then
		echo "Swap space usage in Bytes"
	fi
	case $SORT_KEY in
	    1 )
		echo "Sort by swap space used"
		;;
	    2 )
		echo "Sort by PID"
		;;
	    3 )
		echo "Sort by process name"
		;;
	esac
	echo "----------------------------------------"
	if [ $OPT_PRINT_BYTES = 0 ]; then
		echo "   PID Swap size  Process name"
	else
		echo "   PID      Swap size  Process name"
	fi
	echo "========================================"
}

#
# printFooter()
#
# Print footer with swap total usage.
#
printFooter() {
	echo "========================================"
	echo "Overall swap used: `getSizeFmt $OVERALL`"
}

################################################################################
#
# main()
#
################################################################################

# Parse command line options
OPTS="$(getopt -o B,h,n,p,q,r,s -l size-in-bytes,help,sort-name,sort-pid,quiet,reverse,sort-size --name "${ME}" -- "$@")" || { usage; exit 1; }
eval set -- "$OPTS"
while true; do
  case "$1" in
    -B | --size-in-bytes )
      OPT_PRINT_BYTES=1
      shift
      ;;
    -h | --help )
      usage
      exit
      ;;
    -n | --sort-name )
      SORT_KEY=3
      SORT_NUMERIC=""
      shift
      ;;
    -p | --sort-pid )
      SORT_KEY=2
      SORT_NUMERIC="-n"
      shift
      ;;
    -q | --quiet )
      OPT_QUIET=1
      shift
      ;;
    -r | --reverse )
      SORT_REVERSE="-r"
      shift
      ;;
    -s | --sort-size )
      SORT_KEY=1
      SORT_NUMERIC="-n"
      shift
      ;;
    -- )
      shift
      break
      ;;
    * )
      usage
      exit 1
      ;;
  esac
done

# Print header
[ $OPT_QUIET -eq 0 ] && printHeader

# print processes using SWAP space sorted by selected key
while read KB PID NAME; do
	OVERALL=$((OVERALL+${KB:-0}))
	echo "`getPIDFmt $PID`   `getSizeFmt $KB`  $NAME" 
done <<< $( getProcsSwapUsage | sort $SORT_NUMERIC $SORT_REVERSE -k ${SORT_KEY},${SORT_KEY} )

# Print footer
[ $OPT_QUIET -eq 0 ] && printFooter

# End Of Script
