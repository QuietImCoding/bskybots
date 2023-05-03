source .env

get_kid() {
    curl -s https://api.flickr.com/services/rest\?api_key\=$FLICKR_KEY\&method\=flickr.photos.search\&text\=kid%20goats%20goat\&sort\=interestingness-desc\&content_type\=0\&format\=json | sed 's/jsonFlickrApi//g' | sed -E -e 's/.{14}$//' -e 's/^.{11}//' | jq '.photo[] | "https://api.flickr.com/services/rest?api_key=" + env.FLICKR_KEY + "&method=flickr.photos.getSizes&format=json&photo_id="+.id' | shuf | head -n 1 | xargs curl -s | sed -E -e 's/^.{14}//' | jq -cr '.sizes.size[]|.source' | tail -n 4 | head -n 1 | xargs wget -O kid.jpg 2>/dev/null
    imsize=$(du -k kid.jpg | awk '{ print $1 }')
    if [[ $imsize -gt 1000 ]]; then
	echo "kid was to big... shrinking"
	mogrify -define jpeg:extent=1000KB kid.jpg 
	imsize=$(du -k kid.jpg | awk '{ print $1 }')
	echo "kid is now $imsize kb"
    fi
}

baaa() { 
    get_kid
    bsky post -r "$1" -i "$PWD/kid.jpg" BAAA
    echo "BAAAED AT $1"
}

send_reply() {
    while read -r target;
    do
	baaa $target &
    done
}

while true;
do
    bsky stream --json --pattern '(?i)/baaa' 2>/dev/null | jq --unbuffered -r '"at://"+.did+"/"+.path' | send_reply
done

	
