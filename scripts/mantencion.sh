#!/bin/bash

FECHA=$(date '+%Y-%m-%d %H:%M:%S')
LOG="/home/pi/logs/mantencion.log"
EMAIL="verdugoper@gmail.com"

echo "$FECHA ðŸ§¹ Iniciando mantenciÃ³n semanal..." | tee -a "$LOG"

# ------------------------------
# 1. ActualizaciÃ³n del sistema operativo
# ------------------------------
echo "$FECHA ðŸ“¦ Actualizando sistema operativo..." | tee -a "$LOG"
sudo apt update && sudo apt full-upgrade -y | tee -a "$LOG"
APT_STATUS=$?

# ------------------------------
# 2. ActualizaciÃ³n de imÃ¡genes Docker
# ------------------------------
echo "$FECHA ðŸ³ Actualizando contenedores Docker..." | tee -a "$LOG"

IMAGENES=(
    "lscr.io/linuxserver/plex:latest"
    "lscr.io/linuxserver/duckdns:latest"
    "portainer/portainer-ce:latest"
    "netdata/netdata:stable"
    "dgongut/docker-controller-bot:latest"
    "adguard/adguardhome:latest"
    "ghcr.io/wg-easy/wg-easy:latest"
    "rustdesk/rustdesk-server:latest"
)

for IMG in "${IMAGENES[@]}"; do
    echo "$FECHA â¬‡ï¸ Pull de $IMG" | tee -a "$LOG"
    docker pull "$IMG" >> "$LOG" 2>&1
    if [ $? -ne 0 ]; then
        echo "$FECHA âŒ Error al actualizar la imagen $IMG" | tee -a "$LOG"
    fi
done

# ------------------------------
# 3. RecreaciÃ³n de stacks Docker
# ------------------------------
echo "$FECHA ðŸ”„ Recreando stacks..." | tee -a "$LOG"

STACKS=(
    "/home/pi/docker/plex/docker-compose.yml"
    "/home/pi/docker/duckdns/docker-compose.yml"
    "/home/pi/docker/portainer/docker-compose.yml"
    "/home/pi/docker/netdata/docker-compose.yml"
    "/home/pi/docker/bot/docker-compose.yml"
    "/home/pi/docker/wire-adguard/docker-compose.yml"
    "/home/pi/docker/rustdesk/docker-compose.yml"
)

for STACK in "${STACKS[@]}"; do
    echo "$FECHA ðŸ”§ Actualizando stack: $STACK" | tee -a "$LOG"
    docker compose -f "$STACK" pull >> "$LOG" 2>&1
    docker compose -f "$STACK" up -d >> "$LOG" 2>&1

    if [ $? -ne 0 ]; then
        echo "$FECHA âŒ Error al recrear el stack $STACK" | tee -a "$LOG"
    fi
done

# ------------------------------
# 4. Limpieza de imÃ¡genes antiguas
# ------------------------------
echo "$FECHA ðŸ§¹ Eliminando imÃ¡genes antiguas..." | tee -a "$LOG"
docker image prune -af | tee -a "$LOG"

# ------------------------------
# 5. RotaciÃ³n automÃ¡tica del log si supera 5 MB
# ------------------------------
LOG_SIZE=$(stat -c%s "$LOG")
MAX_SIZE=$((5 * 1024 * 1024))

if [ $LOG_SIZE -gt $MAX_SIZE ]; then
    echo "$FECHA ðŸ§½ Log excede 5MB, rotando..." | tee -a "$LOG"
    mv "$LOG" "${LOG}.old"
    touch "$LOG"
fi

# ------------------------------
# 6. Reinicio seguro del sistema
# ------------------------------
if [ $APT_STATUS -eq 0 ]; then
    echo "$FECHA ðŸ”„ Reiniciando Raspberry Pi por actualizaciones..." | tee -a "$LOG"
    sudo reboot
else
    echo "$FECHA âš ï¸ No se reinicia porque hubo errores en apt." | tee -a "$LOG"
fi
