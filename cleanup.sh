services=$(ls services/ | sed 's/\..*//g')
for service in $services; do
    echo "~~~ $service ~~~"
    ps aux | grep $service | awk '{ print $2 }' 
    ps aux | grep $service | awk '{ print $2 }' | sudo xargs kill
done

echo "~~~ killing all bsky streams ~~~"
sudo killall bsky 
