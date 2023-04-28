send_meme() {
    post=$(bsky thread --json "$1" | jq -r '.post.record.text')
    echo $post
    template="$(echo $post | cut -d' ' -f2 | sed 's/[^a-z]//g')"
    echo $template
    fname="templates/$template.png"
    text="$(echo $post | cut -d' ' -f3-)"
    echo "Created image with text $text"
    bsky post -r $1 -i $fname "$template meme with text: $text" || echo "SOMETHING IS HORRIBLY AWRY"
    rm $fname
}

send_reply() {
    while read -r target;
    do
	echo $target
	send_meme $target &
    done
}

bsky stream --json --pattern '(?i)/bonk' | jq -r --unbuffered '"at://"+.did+"/"+.path' | send_reply