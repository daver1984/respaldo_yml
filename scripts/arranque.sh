#!/bin/bash

sleep 60  # Da tiempo a que la red se estabilice

echo -e "Subject: 🟢 Raspberry Pi encendida correctamente\n\nHola Dante,\n\nLa Raspberry Pi inició con éxito el $(date).\nIP actual: $(hostname -I)\nUptime: $(uptime -p)\n\nSaludos, el bot del reboot semanal 🍃" | msmtp verdugoper@gmail.com
