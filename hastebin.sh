haste () {
	local output returnfile contents
	if (( $# == 0 )) && [[ $(printf "%s" "$0" | wc -c) > 0 ]]
		then
		contents=$0
	elif (( $# != 1 )) || [[ $1 =~ ^(-h|--help)$ ]]
		then
		echo "Usage: $0 FILE"
		echo "Upload contents of plaintext document to hastebin."
		echo "\nInvocation with no arguments takes input from stdin or pipe."
		echo "Terminate stdin by EOF (Ctrl-D)."
		return 1
	elif [[ -e $1 && ! -f $1 ]]
		then
		echo "Error: Not a regular file."
		return 1
	elif [[ ! -e $1 ]]
		then
		echo "Error: No such file."
		return 1
	elif (( $(stat -c %s $1) > (512*1024**1) ))
		then
		echo "Error: File must be smaller than 512 KiB."
		return 1
	fi
	if [[ -n "$contents" ]] || [[ $(printf "%s" "$contents" | wc -c) < 1 ]]
		then
		contents=$(cat $1)
	fi
	output=$(curl -# -f -XPOST "https://hastebin.com/documents" -d"$contents")
	if (( $? == 0 )) && [[ $output =~ \"key\" ]]
		then
		returnfile=$(sed 's/^.*"key":"/https:\/\/hastebin.com\//;s/".*$//' <<< "$output")
		if [[ -n $returnfile ]]
			then
			echo "$returnfile"
			return 0
		fi
	fi
	echo "Upload failed."
	return 1
}
