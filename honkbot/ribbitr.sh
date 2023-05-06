source .env

get_froggie() {
    curl -s https://api.flickr.com/services/rest\?api_key\=$FLICKR_KEY\&method\=flickr.photos.search\&text\=frog%20frogs%20amphibian%20nature\&sort\=interestingness-desc\&content_type\=0\&format\=json | sed 's/jsonFlickrApi//g' | sed -E -e 's/.{14}$//' -e 's/^.{11}//' | jq '.photo[] | "https://api.flickr.com/services/rest?api_key=" + env.FLICKR_KEY + "&method=flickr.photos.getSizes&format=json&photo_id="+.id' | shuf | head -n 1 | xargs curl -s | sed -E -e 's/^.{14}//' | jq -cr '.sizes.size[]|.source' | tail -n 4 | head -n 1 | xargs wget -O froggie.jpg 2>/dev/null
    imsize=$(du -k froggie.jpg | awk '{ print $1 }')
    if [[ $imsize -gt 1000 ]]; then
	echo "froggie was to big... shrinking"
	mogrify -define jpeg:extent=1000KB froggie.jpg 
	imsize=$(du -k froggie.jpg | awk '{ print $1 }')
	echo "froggie is now $imsize kb"
    fi
}

ribbit() { 
    get_froggie
    bsky post -r "$1" -i "$PWD/froggie.jpg" RIBBIT
    echo "RIBBITED AT $1"
}

send_reply() {
    while read -r target;
    do
	ribbit $target &
    done
}

while true;
do
    bsky stream --json --pattern '(?i)/ribbit' 2>/dev/null | jq --unbuffered -r '"at://"+.did+"/"+.path' | send_reply
done

	
