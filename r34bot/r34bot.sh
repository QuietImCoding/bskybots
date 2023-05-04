get_nude() {
    post=$(bsky thread --json "$1" | jq -r '.post.record.text')
    text="$(echo $post | cut -d' ' -f2-)"
    fname=$(echo $text | tr -cd '[:alpha:]')
    uri=$(echo $text | jq -Rr '.|@uri')
    echo $uri
    curl -s "https://api.rule34.xxx/index.php?page=dapi&s=post&q=index&json=1&limit=100&tags=$uri" | jq -r '.[] | .sample_url' | grep 'jpg$' | shuf | head -n 1 | xargs wget -O $fname.jpg
    imsize=$(du -k $fname.jpg | awk '{ print $1 }')
    if [[ $imsize -gt 1000 ]]; then
	echo "$fname was to big... shrinking"
	mogrify -define jpeg:extent=1000KB $fname.jpg 
	imsize=$(du -k $fname.jpg | awk '{ print $1 }')
	echo "$fname is now $imsize kb"
    fi
    echo $fname
    bsky post -r "$1" -i "$PWD/$fname.jpg" $text
    echo "posted $fname AT $1"
    rm $fname.jpg
}

send_reply() {
    while read -r target;
    do
	get_nude $target &
    done
}

while true;
do
    bsky stream --json --pattern '(?i)/rule34' 2>/dev/null | jq --unbuffered -r '"at://"+.did+"/"+.path' | send_reply
done

	
