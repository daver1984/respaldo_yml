#!/bin/bash

FECHA=$(date '+%Y-%m-%d %H:%M:%S')
LOG="/home/pi/logs/actualizacion.log"
EMAIL="verdugoper@gmail.com"

mkdir -p /home/pi/logs
touch "$LOG"
chown pi:pi "$LOG"
chmod 644 "$LOG"

# Esperar conectividad
until ping -c1 8.8.8.8 &>/dev/null; do
    echo "$FECHA ⏳ Esperando red..." | tee -a "$LOG"
    sleep 10
done

echo "$FECHA 🚀 Inicio de actualización..." | tee -a "$LOG"
sudo apt update && sudo apt upgrade -y | tee -a "$LOG"

# Enviar resumen por correo
MENSAJE="Actualización completa.\n\n$(tail -n 30 "$LOG")"
echo -e "Subject: 🔄 [$FECHA] Actualización semanal\n\n$MENSAJE" | msmtp "$EMAIL"

# Reinicio
echo "$FECHA 🔄 Reiniciando Raspberry..." | tee -a "$LOG"
sudo reboot
