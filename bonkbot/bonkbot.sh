send_meme() {
    post=$(bsky thread --json "$1" | jq -r '.post.record.text')
    echo $post
    template="$(echo $post | cut -d' ' -f2 | sed 's/[^a-z]//g')"
    echo $template
    fname="templates/$template.png"
    text="$(echo $post | cut -d' ' -f3-)"
    echo "Created image with text $text"
    bsky post -r $1 -i $fname "$template bonk: $text" || echo "SOMETHING IS HORRIBLY AWRY"
}

send_reply() {
    while read -r target;
    do
	echo $target
	send_meme $target &
    done
}

while true; do
    bsky stream --json --pattern '(?i)^/bonk' 2>/dev/null | jq -r --unbuffered '"at://"+.did+"/"+.path' | send_reply
done
