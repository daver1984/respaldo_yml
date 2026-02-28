#!/bin/bash

FECHA=$(date '+%Y-%m-%d %H:%M:%S')
LOG="/home/pi/logs/mantencion.log"
EMAIL="verdugoper@gmail.com"

echo "$FECHA ðŸ” VerificaciÃ³n post-reinicio iniciada." | tee -a "$LOG"

# ------------------------------
# 1. Lista REAL de contenedores
# ------------------------------
CONTENEDORES=(
    "hbbr"
    "hbbs"
    "duckdns"
    "plex"
    "netdata"
    "portainer"
    "docker-controller-bot"
    "adguardhome"
    "wg-easy"
    "jellyfin"
)

# ------------------------------
# 2. Esperar a que Docker estÃ© operativo
# ------------------------------
echo "$FECHA â³ Esperando que Docker estÃ© listo..." | tee -a "$LOG"
until docker info >/dev/null 2>&1; do
    sleep 5
done
echo "$FECHA ðŸ³ Docker operativo." | tee -a "$LOG"

# ------------------------------
# 3. Esperar a que los contenedores aparezcan
# ------------------------------
for NAME in "${CONTENEDORES[@]}"; do
    echo "$FECHA â³ Esperando que '$NAME' aparezca..." | tee -a "$LOG"

    TIMEOUT=0
    until docker ps --format "{{.Names}}" | grep -qi "$NAME"; do
        sleep 5
        TIMEOUT=$((TIMEOUT+5))

        # Evitar loops infinitos
        if [ $TIMEOUT -ge 120 ]; then
            echo "$FECHA âŒ '$NAME' no apareciÃ³ en docker ps despuÃ©s de 2 minutos." | tee -a "$LOG"
            break
        fi
    done
done

# ------------------------------
# 4. VerificaciÃ³n final de estado y salud
# ------------------------------
echo "$FECHA ðŸ”Ž Verificando estado final de contenedores..." | tee -a "$LOG"

for NAME in "${CONTENEDORES[@]}"; do
    ESTADO=$(docker inspect -f '{{.State.Status}}' "$NAME" 2>/dev/null)
    SALUD=$(docker inspect -f '{{.State.Health.Status}}' "$NAME" 2>/dev/null)

    if [ "$ESTADO" = "running" ]; then
        if [ "$SALUD" = "healthy" ] || [ -z "$SALUD" ]; then
            echo "$FECHA âœ… '$NAME' funcionando correctamente." | tee -a "$LOG"
        else
            echo "$FECHA âš ï¸ '$NAME' corriendo pero no saludable: $SALUD" | tee -a "$LOG"
        fi
    else
        echo "$FECHA âŒ '$NAME' NO estÃ¡ funcionando. Estado: $ESTADO" | tee -a "$LOG"
    fi
done

# ------------------------------
# 5. RotaciÃ³n del log si supera 5MB
# ------------------------------
LOG_SIZE=$(stat -c%s "$LOG")
MAX_SIZE=$((5 * 1024 * 1024))

if [ $LOG_SIZE -gt $MAX_SIZE ]; then
    echo "$FECHA ðŸ§½ Log excede 5MB, rotando..." | tee -a "$LOG"
    mv "$LOG" "${LOG}.old"
    touch "$LOG"
fi

# ------------------------------
# 6. EnvÃ­o de correo con resumen
# ------------------------------
ASUNTO="[$FECHA] ðŸ§© VerificaciÃ³n post-reinicio Raspberry Pi"
MENSAJE="Resumen:\n\n$(tail -n 40 "$LOG")"

echo -e "Subject: $ASUNTO\nFrom: $EMAIL\nTo: $EMAIL\n\n$MENSAJE" | msmtp -a default "$EMAIL"
echo "$FECHA ðŸ“§ Correo enviado." | tee -a "$LOG"
