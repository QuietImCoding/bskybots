echo sudo systemctl daemon-reload
for service in $(ls services);
do
    echo sudo systemctl restart $service
done
