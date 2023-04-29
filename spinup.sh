services=$(ls services/)
for service in $services; do
    sudo systemctl restart $service
done

