stylist="{{ subid }}"
if [ $# -ne 1 ]
then echo OVERVIEW: Make Admitad links for stylists as Stencil HTML.
	echo
	echo "USAGE: $0 <links-file>"
	echo
	echo "	<links-file> should list affiliate links, one by line."
	echo "	Lines without 'http' inside are ignored."
	echo "	?subid=$stylist or &subid=$stylist is added at the end of each url."
	echo
	exit 1
fi
cat header.stencil | sed "s/{{ stylist }}/$stylist/"
cat $1 | while read -r link
do	if [[ $link == *"http"* ]]
	then	if [[ $link == *"?"*  ]]
			then url="$link&subid=$stylist"
			else url="$link?subid=$stylist"
			fi
			echo "<a href=\"$url\">$url</a><br>"
	else	echo "<br>"
			echo "$link<br>"
	fi
done
cat footer.stencil
