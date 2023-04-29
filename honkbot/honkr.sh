source .env

echo $FLICKR_KEY
get_goose() {
    curl https://api.flickr.com/services/rest\?api_key\=$FLICKR_KEY\&method\=flickr.photos.search\&text\=goose%20geese%20bird\&sort\=interestingness-desc\&content_type\=0\&format\=json | sed 's/jsonFlickrApi//g' | sed -E -e 's/.{14}$//' -e 's/^.{11}//' | jq '.photo[] | "https://api.flickr.com/services/rest?api_key=" + env.FLICKR_KEY + "&method=flickr.photos.getSizes&format=json&photo_id="+.id' -r | shuf | head -n 1 | xargs curl | sed -E -e 's/^.{14}//' | jq -cr '.sizes.size[]|.source' | tail -n 4 | head -n 1 | xargs wget -O goose.jpg
}

honk() { 
    get_goose
    bsky post -r "$1" -i "$PWD/goose.jpg" HONK
    echo "HONKED AT $1"
}

send_reply() {
    while read -r target;
    do
	honk $target &
    done
}

while true;
do
    bsky stream --pattern '(?i)/honk' 2>/dev/null | jq --unbuffered -r '"at://"+.did+"/"+.path' | send_reply
done

	
