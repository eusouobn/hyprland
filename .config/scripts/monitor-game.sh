#!/bin/bash

# Desabilita o Monitor VGA
hyprctl eval 'hl.monitor({ output = "HDMI-A-2", disabled = true })'
sleep 1

# Habilita o Monitor HDMI principal com VRR/FreeSync ativado (modo 1 - fullscreen only)
hyprctl eval 'hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@74.97", position = "0x0", scale = 1, vrr = 1 })'

# Notificação visual
notify-send "Monitor Ativo: HDMI (1920x1080@75Hz) - FreeSync (VRR)"
