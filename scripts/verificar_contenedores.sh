#!/bin/bash

FECHA=$(date '+%Y-%m-%d %H:%M:%S')
LOG="/home/pi/logs/verificacion_contenedores.log"
EMAIL="verdugoper@gmail.com"
ASUNTO="🔍 [$FECHA] Estado de contenedores + recuperación"
STATUS_GENERAL="OK"
REINICIADOS=()

# 🧱 Preparar carpeta y log
mkdir -p /home/pi/logs
[ ! -f "$LOG" ] && touch "$LOG"
chown pi:pi "$LOG"
chmod 644 "$LOG"

# 🚫 Validar log
if [ ! -w "$LOG" ]; then
    echo "$FECHA ❌ No se puede escribir en el log: $LOG"
    exit 1
fi

echo "$FECHA 🔄 [INICIO] Verificación + recuperación de contenedores post-reinicio." | tee -a "$LOG"

# 🐳 Servicios a revisar
SERVICIOS=("bot" "duckdns" "homeassistant" "netdata" "plex" "portainer" "wire-adguard")

for SVC in "${SERVICIOS[@]}"; do
    ESTADO=$(docker inspect -f '{{.State.Status}}' "$SVC" 2>/dev/null)

    if [ "$ESTADO" = "running" ]; then
        echo "$FECHA ✅ '$SVC' funcionando correctamente." | tee -a "$LOG"
    elif [ "$ESTADO" = "exited" ] || [ "$ESTADO" = "dead" ]; then
        echo "$FECHA ⚠️ '$SVC' está detenido. Intentando reiniciar..." | tee -a "$LOG"
        docker start "$SVC" &>/dev/null

        # ⏳ Verificar si revivió
        ESTADO_POST=$(docker inspect -f '{{.State.Status}}' "$SVC" 2>/dev/null)
        if [ "$ESTADO_POST" = "running" ]; then
            echo "$FECHA ♻️ '$SVC' reiniciado exitosamente." | tee -a "$LOG"
            REINICIADOS+=("$SVC")
        else
            echo "$FECHA ❌ Falló el reinicio de '$SVC'. Estado actual: $ESTADO_POST" | tee -a "$LOG"
            STATUS_GENERAL="FALLIDO"
        fi
    else
        echo "$FECHA ❓ Estado desconocido para '$SVC': '$ESTADO'" | tee -a "$LOG"
        STATUS_GENERAL="FALLIDO"
    fi
done

# 📨 Envío de correo
ASUNTO="🔍 [$FECHA] Contenedores — ${STATUS_GENERAL} | Reiniciados: ${#REINICIADOS[@]}"
MENSAJE="Resumen de la verificación:\n\n$(tail -n 30 "$LOG")"

if getent hosts smtp.gmail.com > /dev/null; then
    echo "$FECHA 📬 Enviando correo..." | tee -a "$LOG"
    echo -e "Subject: $ASUNTO\n\n$MENSAJE" | msmtp "$EMAIL"
else
    echo "$FECHA ⚠️ No se pudo resolver smtp.gmail.com. Correo omitido." | tee -a "$LOG"
fi

echo "$FECHA 🟢 Verificación + recuperación completada." | tee -a "$LOG"
