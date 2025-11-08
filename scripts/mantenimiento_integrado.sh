#!/bin/bash

FECHA=$(date '+%Y-%m-%d %H:%M:%S')
LOG="/home/pi/logs/mantenimiento_integrado.log"
EMAIL="verdugoper@gmail.com"
STATUS_GENERAL="EXITOSO"
REINICIADOS=()

mkdir -p /home/pi/logs
[ ! -f "$LOG" ] && touch "$LOG"
chown pi:pi "$LOG"
chmod 644 "$LOG"

if [ ! -w "$LOG" ]; then
    echo "$FECHA ❌ No se puede escribir en el log: $LOG"
    exit 1
fi

echo "$FECHA 🛠️ [INICIO] Mantenimiento integrado iniciado." | tee -a "$LOG"

# 🌐 Verificar conectividad
ping -c 1 8.8.8.8 > /dev/null || {
    echo "$FECHA ⚠️ Sin conectividad, reintentando..." | tee -a "$LOG"
    sleep 30
    ping -c 1 8.8.8.8 > /dev/null || {
        echo "$FECHA ❌ Error de conectividad tras reintento." | tee -a "$LOG"
        STATUS_GENERAL="FALLIDO"
        exit 1
    }
}
echo "$FECHA 🌐 Conectividad confirmada." | tee -a "$LOG"

# 📦 Actualización del sistema
echo "$FECHA 📦 Ejecutando apt update..." | tee -a "$LOG"
sudo apt update >> "$LOG" 2>&1 || STATUS_GENERAL="FALLIDO"

echo "$FECHA 📦 Ejecutando apt upgrade..." | tee -a "$LOG"
sudo apt upgrade -y >> "$LOG" 2>&1 || STATUS_GENERAL="FALLIDO"

echo "$FECHA 📦 Ejecutando autoremove..." | tee -a "$LOG"
sudo apt autoremove -y >> "$LOG" 2>&1 || STATUS_GENERAL="FALLIDO"

# 🐳 Contenedores Docker
SERVICIOS=("bot" "duckdns" "netdata" "plex" "portainer" "wire-adguard")

for SVC in "${SERVICIOS[@]}"; do
    echo "$FECHA 🐳 Pull: $SVC" | tee -a "$LOG"
    cd /home/pi/docker/$SVC || { echo "$FECHA ❌ Carpeta no encontrada: $SVC" | tee -a "$LOG"; STATUS_GENERAL="FALLIDO"; continue; }
    docker compose pull >> "$LOG" 2>&1
    [ $? -eq 0 ] && echo "$FECHA ✅ Pull exitoso: $SVC" | tee -a "$LOG" || STATUS_GENERAL="FALLIDO"
done

for SVC in "${SERVICIOS[@]}"; do
    echo "$FECHA 🔁 Reinicio: $SVC" | tee -a "$LOG"
    cd /home/pi/docker/$SVC || continue
    docker compose up -d --remove-orphans >> "$LOG" 2>&1
    [ $? -eq 0 ] && echo "$FECHA ✅ Reinicio exitoso: $SVC" | tee -a "$LOG" || STATUS_GENERAL="FALLIDO"
done

# 🧹 Limpieza de imágenes antiguas
echo "$FECHA 🧹 Eliminando imágenes antiguas..." | tee -a "$LOG"
docker image prune -a -f >> "$LOG" 2>&1 || STATUS_GENERAL="FALLIDO"

# 🧪 Verificación de contenedores
for SVC in "${SERVICIOS[@]}"; do
    ESTADO=$(docker inspect -f '{{.State.Status}}' "$SVC" 2>/dev/null)
    if [ "$ESTADO" = "running" ]; then
        echo "$FECHA ✅ '$SVC' funcionando correctamente." | tee -a "$LOG"
    elif [ "$ESTADO" = "exited" ] || [ "$ESTADO" = "dead" ]; then
        echo "$FECHA ⚠️ '$SVC' detenido. Intentando reiniciar..." | tee -a "$LOG"
        docker start "$SVC" &>/dev/null
        ESTADO_POST=$(docker inspect -f '{{.State.Status}}' "$SVC" 2>/dev/null)
        if [ "$ESTADO_POST" = "running" ]; then
            echo "$FECHA ✅ '$SVC' reiniciado exitosamente." | tee -a "$LOG"
            REINICIADOS+=("$SVC")
        else
            echo "$FECHA ❌ Falló el reinicio de '$SVC'. Estado: $ESTADO_POST" | tee -a "$LOG"
            STATUS_GENERAL="FALLIDO"
        fi
    else
        echo "$FECHA ❌ Estado desconocido para '$SVC': $ESTADO" | tee -a "$LOG"
        STATUS_GENERAL="FALLIDO"
    fi
done

# 📬 Envío de correo
ASUNTO="[$FECHA] 🧩 Mantenimiento Raspberry Pi — ${STATUS_GENERAL} | Reiniciados: ${#REINICIADOS[@]}"
MENSAJE="Resumen de ejecución:\n\n$(tail -n 30 "$LOG")"

if getent hosts smtp.gmail.com > /dev/null; then
    echo "$FECHA 📬 Enviando correo..." | tee -a "$LOG"
    echo -e "Subject: $ASUNTO\n\n$MENSAJE" | msmtp "$EMAIL"
else
    echo "$FECHA ⚠️ No se pudo resolver smtp.gmail.com. Correo omitido." | tee -a "$LOG"
fi

# 🏁 Finalización
echo "$FECHA 🏁 Script finalizado con estado: $STATUS_GENERAL" | tee -a "$LOG"

# 🔄 Reinicio condicional
if [ "$STATUS_GENERAL" = "EXITOSO" ]; then
    echo "$FECHA 🔄 Reiniciando Raspberry Pi por mantenimiento exitoso." | tee -a "$LOG"
    sudo reboot
else
    echo "$FECHA ❌ Mantenimiento con errores, no se reinicia." | tee -a "$LOG"
fi
