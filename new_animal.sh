read -p "sound: " sound 
read -p "cute name: " cutename
read -p "plural name: " pluralname
read -p "category: " category

capsound=$(echo $sound | tr a-z A-Z)

cat honkbot/honkr.sh | sed -e "s/honk/$sound/g" \
			   -e "s/HONK/$capsound/g" \
			   -e "s/goose/$cutename/g" \
			   -e "s/geese/$pluralname/g" \
			   -e "s/bird/$category/g" | tee honkbot/${sound}r.sh

cat services/honk.service | sed "s/honkr/${sound}r/g" | tee services/$sound.service

