sudo apt-get update -y
sudo apt-get dist-upgrade -y
sudo apt-get autoremove -y
sudo apt-get autoclean -y
cd /home/pi/docker/bot
sudo docker compose pull
sudo docker compose up -d --remove-orphans
sudo docker image prune -f
cd /home/pi/docker/duckdns
sudo docker compose pull
sudo docker compose up -d --remove-orphans
sudo docker image prune -f
cd /home/pi/docker/homeasistant
sudo docker compose pull
sudo docker compose up -d --remove-orphans
sudo docker image prune -f
cd /home/pi/docker/jellyfin
sudo docker compose pull
sudo docker compose up -d --remove-orphans
sudo docker image prune -f
cd /home/pi/docker/minecraft
sudo docker compose pull && sudo docker compose down && sudo docker compose up -d --remove-orphans
sudo docker image prune -f
cd /home/pi/docker/netdata
sudo docker compose pull
sudo docker compose up -d --remove-orphans
sudo docker image prune -f
cd /home/pi/docker/plex
sudo docker compose pull
sudo docker compose up -d --remove-orphans
sudo docker image prune -f
cd /home/pi/docker/portainer
sudo docker compose pull
sudo docker compose up -d --remove-orphans
sudo docker image prune -f
cd /home/pi/docker/wg-pihole
sudo docker compose pull
sudo docker compose up -d --remove-orphans
sudo docker image prune -f