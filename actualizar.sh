sudo apt-get update -y
sudo apt-get dist-upgrade -y
sudo apt-get autoremove -y
sudo apt-get autoclean -y
sudo docker stop portainer
sudo docker rm portainer
sudo docker pull portainer/portainer-ce
sudo docker run -d --name=portainer --hostname=portainer --network=host --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data -e TZ='America/Santiago' portainer/portainer-ce
cd /home/pi/docker/plex
sudo docker compose pull
sudo docker compose up -d --remove-orphans
sudo docker image prune -f
cd /home/pi/docker/jellyfin
sudo docker compose pull
sudo docker compose up -d --remove-orphans
sudo docker image prune -f
cd /home/pi/docker/homeassistant
sudo docker compose pull
sudo docker compose up -d --remove-orphans
sudo docker image prune -f
cd /home/pi/docker/mysql
sudo docker compose pull
sudo docker compose up -d --remove-orphans
sudo docker image prune -f
cd /home/pi/docker/duckdns
sudo docker compose pull
sudo docker compose up -d --remove-orphans
sudo docker image prune -f
cd /home/pi/docker/wgeasy
sudo docker compose pull
sudo docker compose up -d --remove-orphans
sudo docker image prune -f
cd /home/pi/docker/netdata
sudo docker compose pull
sudo docker compose up -d --remove-orphans
sudo docker image prune -f
cd /home/pi/docker/bot
sudo docker compose pull
sudo docker compose up -d --remove-orphans
sudo docker image prune -f
#sudo shutdown -r now
