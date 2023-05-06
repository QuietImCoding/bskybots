sudo systemctl daemon-reload
sudo systemctl stop $1 &&
    ps aux | grep $1 | awk '{ print $2 }' | sudo xargs kill;
sudo systemctl start $1
