bees() {
    line="$(cat beemovie.txt | sort | tail +2589 | shuf | head -n 1)"
    reply=$(echo "$line" | bsky post -r $1 --stdin)
}

send_reply() {
    while read -r target;
    do
	bees $target &
    done
}

while true; do
    bsky stream --pattern '(?i)/beemovie' 2>/dev/null | jq -r --unbuffered '"at://"+.did+"/"+.path' | send_reply
done
