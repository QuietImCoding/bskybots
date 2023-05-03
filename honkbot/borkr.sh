source .env

get_pupper() {
    curl -s https://api.flickr.com/services/rest\?api_key\=$FLICKR_KEY\&method\=flickr.photos.search\&text\=pupper%20puppies%20dog\&sort\=interestingness-desc\&content_type\=0\&format\=json | sed 's/jsonFlickrApi//g' | sed -E -e 's/.{14}$//' -e 's/^.{11}//' | jq '.photo[] | "https://api.flickr.com/services/rest?api_key=" + env.FLICKR_KEY + "&method=flickr.photos.getSizes&format=json&photo_id="+.id' | shuf | head -n 1 | xargs curl -s | sed -E -e 's/^.{14}//' | jq -cr '.sizes.size[]|.source' | tail -n 4 | head -n 1 | xargs wget -O pupper.jpg 2>/dev/null
    imsize=$(du -k pupper.jpg | awk '{ print $1 }')
    if [[ $imsize -gt 1000 ]]; then
	echo "pupper was to big... shrinking"
	mogrify -define jpeg:extent=1000KB pupper.jpg 
	imsize=$(du -k pupper.jpg | awk '{ print $1 }')
	echo "pupper is now $imsize kb"
    fi
}

bork() { 
    get_pupper
    bsky post -r "$1" -i "$PWD/pupper.jpg" BORK
    echo "BORKED AT $1"
}

send_reply() {
    while read -r target;
    do
	bork $target &
    done
}

while true;
do
    bsky stream --json --pattern '(?i)/bork' 2>/dev/null | jq --unbuffered -r '"at://"+.did+"/"+.path' | send_reply
done

	
