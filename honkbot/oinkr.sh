source .env

get_piglet() {
    curl -s https://api.flickr.com/services/rest\?api_key\=$FLICKR_KEY\&method\=flickr.photos.search\&text\=pig%20piggy%20oink%20farm\&sort\=interestingness-desc\&content_type\=0\&format\=json | sed 's/jsonFlickrApi//g' | sed -E -e 's/.{14}$//' -e 's/^.{11}//' | jq '.photo[] | "https://api.flickr.com/services/rest?api_key=" + env.FLICKR_KEY + "&method=flickr.photos.getSizes&format=json&photo_id="+.id' | shuf | head -n 1 | xargs curl -s | sed -E -e 's/^.{14}//' | jq -cr '.sizes.size[]|.source' | tail -n 4 | head -n 1 | xargs wget -O piglet.jpg 2>/dev/null
    imsize=$(du -k piglet.jpg | awk '{ print $1 }')
    if [[ $imsize -gt 1000 ]]; then
	echo "piglet was to big... shrinking"
	mogrify -define jpeg:extent=1000KB piglet.jpg 
	imsize=$(du -k piglet.jpg | awk '{ print $1 }')
	echo "piglet is now $imsize kb"
    fi
}

oink() { 
    get_piglet
    bsky post -r "$1" -i "$PWD/piglet.jpg" OINK
    echo "OINKED AT $1"
}

send_reply() {
    while read -r target;
    do
	oink $target &
    done
}

while true;
do
    bsky stream --json --pattern '(?i)/oink' 2>/dev/null | jq --unbuffered -r '"at://"+.did+"/"+.path' | send_reply
done

	
