#!/bin/bash

FECHA=$(date '+%Y-%m-%d %H:%M:%S')
LOG="/home/pi/logs/cron_semanal.log"
EMAIL="verdugoper@gmail.com"
STATUS_GENERAL="EXITOSO"

# 🧱 Preparar carpeta y archivo de logs
mkdir -p /home/pi/logs
[ ! -f "$LOG" ] && touch "$LOG"
chown pi:pi "$LOG"
chmod 644 "$LOG"

# 🚫 Validar si se puede escribir en el log
if [ ! -w "$LOG" ]; then
    echo "$FECHA ❌ No se puede escribir en el archivo de log: $LOG"
    exit 1
fi

# 🚀 Inicio del script
echo "$FECHA 🛠️ [INICIO] Script iniciado." | tee -a "$LOG"

# 🧪 Verificar conectividad
ping -c 1 8.8.8.8 > /dev/null
if [ $? -ne 0 ]; then
    echo "$FECHA ⚠️ Sin conectividad, reintentando en 30s..." | tee -a "$LOG"
    sleep 30
    ping -c 1 8.8.8.8 > /dev/null
    if [ $? -ne 0 ]; then
        echo "$FECHA ❌ Error de conectividad tras reintento." | tee -a "$LOG"
        STATUS_GENERAL="FALLIDO"
        exit 1
    fi
fi
echo "$FECHA 📡 Conectividad confirmada." | tee -a "$LOG"

# 📦 Actualizar sistema
echo "$FECHA 🗂️ Ejecutando apt update..." | tee -a "$LOG"
sudo apt update >> "$LOG" 2>&1 || STATUS_GENERAL="FALLIDO"

echo "$FECHA 🗂️ Ejecutando apt upgrade..." | tee -a "$LOG"
sudo apt upgrade -y >> "$LOG" 2>&1 || STATUS_GENERAL="FALLIDO"

echo "$FECHA 🧹 Ejecutando autoremove..." | tee -a "$LOG"
sudo apt autoremove -y >> "$LOG" 2>&1 || STATUS_GENERAL="FALLIDO"

# 🐳 Contenedores Docker
SERVICIOS=("bot" "duckdns" "homeassistant" "netdata" "plex" "portainer" "wire-adguard")

for SVC in "${SERVICIOS[@]}"; do
    echo "$FECHA 📥 Pull: $SVC" | tee -a "$LOG"
    cd /home/pi/docker/$SVC || { echo "$FECHA ❌ No se encontró carpeta: $SVC" | tee -a "$LOG"; STATUS_GENERAL="FALLIDO"; continue; }
    docker compose pull >> "$LOG" 2>&1
    [ $? -eq 0 ] && echo "$FECHA ✅ Pull exitoso: $SVC" | tee -a "$LOG" || { echo "$FECHA ❌ Pull fallido: $SVC" | tee -a "$LOG"; STATUS_GENERAL="FALLIDO"; }
done

for SVC in "${SERVICIOS[@]}"; do
    echo "$FECHA 🔁 Reinicio: $SVC" | tee -a "$LOG"
    cd /home/pi/docker/$SVC || continue
    docker compose up -d --remove-orphans >> "$LOG" 2>&1
    [ $? -eq 0 ] && echo "$FECHA ✅ Reinicio exitoso: $SVC" | tee -a "$LOG" || { echo "$FECHA ❌ Reinicio fallido: $SVC" | tee -a "$LOG"; STATUS_GENERAL="FALLIDO"; }
done

# 🧹 Limpieza de imágenes antiguas de Docker
echo "$FECHA 🧹 Eliminando imágenes antiguas..." | tee -a "$LOG"
docker image prune -a -f >> "$LOG" 2>&1
if [ $? -eq 0 ]; then
    echo "$FECHA ✅ Imágenes antiguas eliminadas correctamente." | tee -a "$LOG"
else
    echo "$FECHA ❌ Error al eliminar imágenes antiguas." | tee -a "$LOG"
    STATUS_GENERAL="FALLIDO"
fi

# 📬 Envío de correo con resumen
ASUNTO="🗂️ [$FECHA] Actualización semanal Raspberry Pi — ${STATUS_GENERAL}"

if getent hosts smtp.gmail.com > /dev/null; then
    echo "$FECHA 📬 Enviando correo..." | tee -a "$LOG"
    echo -e "Subject: $ASUNTO\n\nResumen de ejecución:\n\n$(tail -n 30 "$LOG")" | msmtp "$EMAIL"
else
    echo "$FECHA ⚠️ No se pudo resolver smtp.gmail.com. Correo omitido." | tee -a "$LOG"
fi

# 🏁 Finalización
echo "$FECHA ✅ Script finalizado con estado: $STATUS_GENERAL" | tee -a "$LOG"

# 🔄 Reinicio condicional
if [ "$STATUS_GENERAL" = "EXITOSO" ]; then
    echo "$FECHA 🔄 Reiniciando Raspberry Pi por mantenimiento exitoso." | tee -a "$LOG"
    sudo reboot
else
    echo "$FECHA ❌ Mantenimiento con errores, no se reinicia." | tee -a "$LOG"
fi
