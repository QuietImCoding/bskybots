source .env

get_kitty() {
    curl -s https://api.flickr.com/services/rest\?api_key\=$FLICKR_KEY\&method\=flickr.photos.search\&text\=kitty%20kitties%20cat\&sort\=interestingness-desc\&content_type\=0\&format\=json | sed 's/jsonFlickrApi//g' | sed -E -e 's/.{14}$//' -e 's/^.{11}//' | jq '.photo[] | "https://api.flickr.com/services/rest?api_key=" + env.FLICKR_KEY + "&method=flickr.photos.getSizes&format=json&photo_id="+.id' | shuf | head -n 1 | xargs curl -s | sed -E -e 's/^.{14}//' | jq -cr '.sizes.size[]|.source' | tail -n 4 | head -n 1 | xargs wget -O kitty.jpg 2>/dev/null
    imsize=$(du -k kitty.jpg | awk '{ print $1 }')
    if [[ $imsize -gt 1000 ]]; then
	echo "kitty was to big... shrinking"
	mogrify -define jpeg:extent=1000KB kitty.jpg 
	imsize=$(du -k kitty.jpg | awk '{ print $1 }')
	echo "kitty is now $imsize kb"
    fi
}

meow() { 
    get_kitty
    bsky post -r "$1" -i "$PWD/kitty.jpg" MEOW
    echo "MEOWED AT $1"
}

send_reply() {
    while read -r target;
    do
	meow $target &
    done
}

while true;
do
    bsky stream --json --pattern '(?i)/meow' 2>/dev/null | jq --unbuffered -r '"at://"+.did+"/"+.path' | send_reply
done

	
