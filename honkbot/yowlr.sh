source .env

get_lynx() {
    curl -s https://api.flickr.com/services/rest\?api_key\=$FLICKR_KEY\&method\=flickr.photos.search\&text\=lynx%20bobcats%20bobcat\&sort\=interestingness-desc\&content_type\=0\&format\=json | sed 's/jsonFlickrApi//g' | sed -E -e 's/.{14}$//' -e 's/^.{11}//' | jq '.photo[] | "https://api.flickr.com/services/rest?api_key=" + env.FLICKR_KEY + "&method=flickr.photos.getSizes&format=json&photo_id="+.id' | shuf | head -n 1 | xargs curl -s | sed -E -e 's/^.{14}//' | jq -cr '.sizes.size[]|.source' | tail -n 4 | head -n 1 | xargs wget -O lynx.jpg 2>/dev/null
    imsize=$(du -k lynx.jpg | awk '{ print $1 }')
    if [[ $imsize -gt 1000 ]]; then
	echo "lynx was to big... shrinking"
	mogrify -define jpeg:extent=1000KB lynx.jpg 
	imsize=$(du -k lynx.jpg | awk '{ print $1 }')
	echo "lynx is now $imsize kb"
    fi
}

yowl() { 
    get_lynx
    bsky post -r "$1" -i "$PWD/lynx.jpg" YOWL
    echo "YOWLED AT $1"
}

send_reply() {
    while read -r target;
    do
	yowl $target &
    done
}

while true;
do
    bsky stream --json --pattern '(?i)/yowl' 2>/dev/null | jq --unbuffered -r '"at://"+.did+"/"+.path' | send_reply
done

	
