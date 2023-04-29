ps aux | grep $1 | awk '{ print $2 }' | sudo xargs kill

