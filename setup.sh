for service in $(ls services);
do
    echo sudo ln -s /home/dan/bskybots/services/$service /etc/systemd/system
    echo sudo systemctl enable $service
    echo sudo systemctl start $service
done
