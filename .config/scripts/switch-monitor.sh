#!/bin/bash

# Identificadores dos monitores
MONITOR_GAME="HDMI-A-1"
MONITOR_CAPTURE="HDMI-A-2"

# Verifica qual está ativo
ACTIVE_MONITOR=$(hyprctl monitors | awk '/focused: yes/{print prev} {prev=$2}')

if [ "$ACTIVE_MONITOR" == "$MONITOR_GAME" ]; then
    # Modo gravação
    hyprctl dispatch dpms off "$MONITOR_GAME"
    hyprctl dispatch dpms on "$MONITOR_CAPTURE"
    sleep 1
    hyprctl dispatch focusmonitor "$MONITOR_CAPTURE"
    hyprctl dispatch moveworkspace 1 "$MONITOR_CAPTURE"
    hyprctl dispatch moveworkspace 2 "$MONITOR_CAPTURE"
    hyprctl dispatch moveworkspace 3 "$MONITOR_CAPTURE"
    notify-send "🎥 Modo Captura" "Migrado para $MONITOR_CAPTURE (60 Hz)"
else
    # Modo normal / jogo
    hyprctl dispatch dpms off "$MONITOR_CAPTURE"
    hyprctl dispatch dpms on "$MONITOR_GAME"
    sleep 1
    hyprctl dispatch focusmonitor "$MONITOR_GAME"
    hyprctl dispatch moveworkspace 1 "$MONITOR_GAME"
    hyprctl dispatch moveworkspace 2 "$MONITOR_GAME"
    hyprctl dispatch moveworkspace 3 "$MONITOR_GAME"
    notify-send "🕹️ Modo Jogo" "Migrado para $MONITOR_GAME (75 Hz)"
fi
