source .env

get_capy() {
    curl -s https://api.flickr.com/services/rest\?api_key\=$FLICKR_KEY\&method\=flickr.photos.search\&text\=capy%20capybaras%20capybara\&sort\=interestingness-desc\&content_type\=0\&format\=json | sed 's/jsonFlickrApi//g' | sed -E -e 's/.{14}$//' -e 's/^.{11}//' | jq '.photo[] | "https://api.flickr.com/services/rest?api_key=" + env.FLICKR_KEY + "&method=flickr.photos.getSizes&format=json&photo_id="+.id' | shuf | head -n 1 | xargs curl -s | sed -E -e 's/^.{14}//' | jq -cr '.sizes.size[]|.source' | tail -n 4 | head -n 1 | xargs wget -O capy.jpg 2>/dev/null
    imsize=$(du -k capy.jpg | awk '{ print $1 }')
    if [[ $imsize -gt 1000 ]]; then
	echo "capy was to big... shrinking"
	mogrify -define jpeg:extent=1000KB capy.jpg 
	imsize=$(du -k capy.jpg | awk '{ print $1 }')
	echo "capy is now $imsize kb"
    fi
}

squee() { 
    get_capy
    bsky post -r "$1" -i "$PWD/capy.jpg" SQUEE
    echo "SQUEEED AT $1"
}

send_reply() {
    while read -r target;
    do
	squee $target &
    done
}

while true;
do
    bsky stream --json --pattern '(?i)/squee' 2>/dev/null | jq --unbuffered -r '"at://"+.did+"/"+.path' | send_reply
done

	
