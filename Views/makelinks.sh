if [ $# -ne 2 ]
then echo OVERVIEW: Make joined links file for from separate shop names and links files.
	echo
	echo "USAGE: $0 <names-file> <links-file>"
	echo
	echo "	<names-file> should list shop names, one by line."
    echo "	<links-file> should list shop affiliate links, one by line."
	echo
	exit 1
fi

paste -d"\n" $1 $2
