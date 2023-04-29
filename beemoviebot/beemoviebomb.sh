bees() {
    reply=$1
    for i in `seq $(cat beemovie.txt | wc -l)`;
    do
	line=$(cat beemovie.txt | head -n $i | tail -n 1);
	if [[ ${#line} -gt 2 ]]; then
	    echo $reply ${#line} $i $line
	    reply=$(echo "$line" | bsky post -r $reply --stdin)
	fi;
    done
}

send_reply() {
    while read -r target;
    do
	echo $target 
	bees $target &
    done
}

## This should help with reliability
while true; do
    bsky stream --pattern /beemoviebomb | jq -r --unbuffered '"at://"+.did+"/"+.path' | send_reply
done
