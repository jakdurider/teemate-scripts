sudo rm -f /sharedVolume/*
sudo rm -f /scripts/func.js
sudo rm -f /scripts/result/*
docker stop $(docker ps -a --format '{{.Names}}' --filter name='wsk*')
docker rm $(docker ps -a --format '{{.Names}}' --filter name='wsk*')
python controller.py
