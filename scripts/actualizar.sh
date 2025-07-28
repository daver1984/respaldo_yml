# Archivo de actualización de sistemas.

#Actualizando Raspbian:
sudo apt-get update -y
sudo apt-get dist-upgrade -y
sudo apt-get autoremove -y
sudo apt-get autoclean -y

#Actualizando los Dockers:
cd /home/pi/docker/bot
sudo docker compose pull
sudo docker compose up -d --remove-orphans
sudo docker image prune -f
cd /home/pi/docker/duckdns
sudo docker compose pull
sudo docker compose up -d --remove-orphans
sudo docker image prune -f
cd /home/pi/docker/homeassistant
sudo docker compose pull
sudo docker compose up -d --remove-orphans
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
cd /home/pi/docker/wire-adguard
sudo docker compose pull
sudo docker compose up -d --remove-orphans
sudo docker image prune -f

#Verificacion de archivos antes del reinicio:
echo "Verificando servicios activos antes de reiniciar..." >> "$LOGFILE"
systemctl list-units --type=service --state=running >> "$LOGFILE"

# Envía el correo de confirmación
echo "✅ Reinicio ejecutado exitosamente el $(date)" | msmtp --subject="Confirmación desde Raspberry Pi" verdugoper@gmail.com

# Mensaje y retraso antes del reinicio
echo "Reiniciando en 30 segundos..." >> "$LOGFILE"
sleep 30
sudo reboot
