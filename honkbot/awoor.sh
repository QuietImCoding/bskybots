source .env

get_pup() {
    curl -s https://api.flickr.com/services/rest\?api_key\=$FLICKR_KEY\&method\=flickr.photos.search\&text\=pup%20wolves%20wolf\&sort\=interestingness-desc\&content_type\=0\&format\=json | sed 's/jsonFlickrApi//g' | sed -E -e 's/.{14}$//' -e 's/^.{11}//' | jq '.photo[] | "https://api.flickr.com/services/rest?api_key=" + env.FLICKR_KEY + "&method=flickr.photos.getSizes&format=json&photo_id="+.id' | shuf | head -n 1 | xargs curl -s | sed -E -e 's/^.{14}//' | jq -cr '.sizes.size[]|.source' | tail -n 4 | head -n 1 | xargs wget -O pup.jpg 2>/dev/null
    imsize=$(du -k pup.jpg | awk '{ print $1 }')
    if [[ $imsize -gt 1000 ]]; then
	echo "pup was to big... shrinking"
	mogrify -define jpeg:extent=1000KB pup.jpg 
	imsize=$(du -k pup.jpg | awk '{ print $1 }')
	echo "pup is now $imsize kb"
    fi
}

awoo() { 
    get_pup
    bsky post -r "$1" -i "$PWD/pup.jpg" AWOO
    echo "AWOOED AT $1"
}

send_reply() {
    while read -r target;
    do
	awoo $target &
    done
}

while true;
do
    bsky stream --json --pattern '(?i)/awoo' 2>/dev/null | jq --unbuffered -r '"at://"+.did+"/"+.path' | send_reply
done

	
