# respaldo_yml
Backup de configuraciones .yml

1)Ejecutar manualmente el script de mantención
    Este es el que corre los sábados a las 05:00 AM, pero si quieres probarlo o forzar una mantención:
        sudo /usr/local/bin/mantencion

O simplemente:
    sudo mantencion

Importante:
    Este script reinicia la Raspberry Pi al final, así que si lo ejecutas manualmente, prepárate para el reinicio.

2) Ejecutar manualmente el script de verificación post‑reinicio
    Este es el que normalmente corre solo cuando la Raspberry arranca, pero puedes probarlo cuando quieras:
        sudo /usr/local/bin/verificacion_post_reboot


O simplemente:
    sudo verificacion_post_reboot


Este no reinicia nada, solo:
- espera a que Docker esté listo
- verifica contenedores
- escribe en el log
- envía el correo
Así que es seguro ejecutarlo cuando quieras.

Tip rápido para ver el log después de ejecutarlos
tail -n 50 /home/pi/logs/mantenimiento_integrado.log

Así ves inmediatamente lo que hicieron.