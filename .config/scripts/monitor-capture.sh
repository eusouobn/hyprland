#!/bin/bash

# 1. Desabilita o Monitor HDMI principal (HDMI-A-1)
# O campo 'disabled' remove o monitor do layout e descarta o estado de VRR.
hyprctl eval 'hl.monitor({ output = "HDMI-A-1", disabled = true })'
sleep 1

# 2. Habilita o Monitor VGA (HDMI-A-2) na posição 0x0
# A omissão do campo 'vrr' garante que ele não será ativado neste monitor.
hyprctl eval 'hl.monitor({ output = "HDMI-A-2", mode = "1920x1080@60", position = "0x0", scale = 1 })'

# Notificação visual
notify-send "Monitor Ativo: VGA (1920x1080@60Hz) - VRR DESLIGADO"
