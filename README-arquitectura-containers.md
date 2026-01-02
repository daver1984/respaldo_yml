Sistema de Mantención Automatizada para Raspberry Pi con Docker y Portainer.

Este proyecto implementa un sistema de mantención y verificación completamente automatizado para una Raspberry Pi que opera múltiples servicios en contenedores Docker administrados mediante Portainer. El objetivo es garantizar continuidad operacional, estabilidad post‑reinicio y monitoreo activo sin intervención manual.

El sistema se compone de dos scripts principales:

- Script de Mantención Semanal
    Ejecutado automáticamente todos los sábados a las 05:00 AM.
    Realiza actualización del sistema operativo, actualización de imágenes Docker, recreación de contenedores, limpieza de imágenes antiguas y reinicio controlado del dispositivo.
- Script de Verificación Post‑Reinicio
    Ejecutado automáticamente en cada arranque mediante un servicio systemd.
    Espera a que Docker esté completamente operativo, verifica el estado real de cada contenedor (incluyendo healthchecks), registra los resultados y envía un correo con el estado final del sistema.

    El diseño evita falsos positivos, considera tiempos de arranque variables y utiliza verificación basada en docker ps para asegurar precisión incluso cuando los contenedores son gestionados por Portainer. El sistema está documentado, modularizado y preparado para escalar o integrarse con herramientas de monitoreo adicionales.
