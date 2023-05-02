send_meme() {
    post=$(bsky thread --json "$1" | jq -r '.post.record.text')
    echo $post
    template="$(echo $post | cut -d' ' -f2 | sed 's/[^a-z]//g')"
    echo $template
    tmpfname="${template}_$RANDOM.jpg"
    text="$(echo $post | cut -d' ' -f3-)"
    fontsize=$((2000/(((${#text}+1)/7)**2+1)))
    fontsize=$((fontsize>20 ? $fontsize : 20))
    fontsize=$((fontsize<50 ? $fontsize : 50))
    #convert "./templates/${template}.png" -gravity South -size 800x -pointsize $fontsize caption:"$text" +swap -append +0+800  $PWD/$tmpfname
    convert "./templates/${template}.png" \( \( -gravity north -splice 0x50 \) -size 800x -pointsize 30 caption:"$text" \( -gravity south -splice 0x50 \)  \) -append -define jpeg:extent=1000KB $PWD/$tmpfname
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

while true; do 
    bsky stream --json --pattern '(?i)^/meme' 2>/dev/null | jq -r --unbuffered '"at://"+.did+"/"+.path' | send_reply
done
