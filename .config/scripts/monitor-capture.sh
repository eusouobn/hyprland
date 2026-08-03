#!/bin/bash

# 1. Desabilita o Monitor HDMI principal (HDMI-A-1)
# O comando 'disable' remove o monitor do layout e descarta o estado de VRR.
hyprctl keyword monitor "HDMI-A-1, disable"
sleep 1

# 2. Habilita o Monitor VGA (HDMI-A-2) na posição 0x0
# A omissão do parâmetro 'vrr' garante que ele não será ativado neste monitor.
hyprctl keyword monitor "HDMI-A-2, 1920x1080@60, 0x0, 1"

# Notificação visual
notify-send "Monitor Ativo: VGA (1920x1080@60Hz) - VRR DESLIGADO"
