# 🔐 Infraestructura Raspberry Pi — Verificación de Contenedores & Actualización de Sistema

Este repositorio incluye dos scripts clave para la operación automática post-reinicio y mantenimiento programado en una Raspberry Pi con Docker.

---

## 🧠 Scripts incluidos

### 1. `verificar_contenedores.sh`

Verifica el estado de contenedores Docker y reinicia aquellos detenidos. Registra logs y envía resumen por correo.

- Ruta recomendada: `/home/pi/scripts/verificar_contenedores.sh`
- Requiere tener configurado `msmtp` para envío de correos.
- Guarda logs en: `/home/pi/logs/verificacion_contenedores.log`

### 2. `actualizar.sh`

Ejecuta actualizaciones del sistema (paquetes APT), reinicia la Raspberry Pi y notifica por correo.

- Ruta recomendada: `/home/pi/scripts/actualizar.sh`
- Incluye validación de conectividad y logs.
- Ejecutado automáticamente cada lunes a las 05:00 AM.

---

## ⚙️ Configuración de tareas automáticas con `crontab`

Para configurar estas tareas, seguí estos pasos:

### 🛠️ Editar el crontab

Desde la terminal, ejecutá:

```bash
crontab -e
