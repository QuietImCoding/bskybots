send_meme() {
    post=$(bsky thread --json "$1" | jq -r '.post.record.text')
    echo $post
    template="$(echo $post | cut -d' ' -f2 | sed 's/[^a-z]//g')"
    echo $template
    tmpfname="${template}_$RANDOM.png"
    text="$(echo $post | cut -d' ' -f3-)"
    fontsize=$((2000/(((${#text}+1)/7)**2+1)))
    fontsize=$((fontsize>20 ? $fontsize : 20))
    fontsize=$((fontsize<50 ? $fontsize : 50))
    convert "./templates/${template}.png" -gravity South -pointsize $fontsize -annotate +0+100 "$text" $PWD/$tmpfname
    echo "Created image with text $text in $PWD/$tmpfname"
    bsky post -r $1 -i $PWD/$tmpfname "$template meme with text: $text" && rm $tmpfname
}

send_reply() {
    pwd
    while read -r target;
    do
	echo $target
	send_meme $target &
    done
}

bsky stream --pattern '(?i)/meme' | jq -r --unbuffered '"at://"+.did+"/"+.path' | send_reply
