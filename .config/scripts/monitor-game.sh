#!/bin/bash

# Desabilita o Monitor VGA
hyprctl keyword monitor "HDMI-A-2, disable"
sleep 1

# Habilita o Monitor HDMI principal com VRR/FreeSync ativado (modo 1 - fullscreen only)
hyprctl keyword monitor "HDMI-A-1, 1920x1080@74.97, 0x0, 1, vrr, 1"

# Notificação visual
notify-send "Monitor Ativo: HDMI (1920x1080@75Hz) - FreeSync (VRR)"
