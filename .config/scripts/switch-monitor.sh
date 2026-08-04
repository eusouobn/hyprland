#!/bin/bash

# Identificadores dos monitores
MONITOR_GAME="HDMI-A-1"
MONITOR_CAPTURE="HDMI-A-2"

# Verifica qual está ativo
ACTIVE_MONITOR=$(hyprctl monitors | awk '/focused: yes/{print prev} {prev=$2}')

if [ "$ACTIVE_MONITOR" == "$MONITOR_GAME" ]; then
    # Modo gravação
    hyprctl dispatch 'hl.dsp.dpms({ action = "off", monitor = "'$MONITOR_GAME'" })'
    hyprctl dispatch 'hl.dsp.dpms({ action = "on", monitor = "'$MONITOR_CAPTURE'" })'
    sleep 1
    hyprctl dispatch 'hl.dsp.focus({ monitor = "'$MONITOR_CAPTURE'" })'
    hyprctl dispatch 'hl.dsp.workspace.move({ workspace = 1, monitor = "'$MONITOR_CAPTURE'" })'
    hyprctl dispatch 'hl.dsp.workspace.move({ workspace = 2, monitor = "'$MONITOR_CAPTURE'" })'
    hyprctl dispatch 'hl.dsp.workspace.move({ workspace = 3, monitor = "'$MONITOR_CAPTURE'" })'
    notify-send "🎥 Modo Captura" "Migrado para $MONITOR_CAPTURE (60 Hz)"
else
    # Modo normal / jogo
    hyprctl dispatch 'hl.dsp.dpms({ action = "off", monitor = "'$MONITOR_CAPTURE'" })'
    hyprctl dispatch 'hl.dsp.dpms({ action = "on", monitor = "'$MONITOR_GAME'" })'
    sleep 1
    hyprctl dispatch 'hl.dsp.focus({ monitor = "'$MONITOR_GAME'" })'
    hyprctl dispatch 'hl.dsp.workspace.move({ workspace = 1, monitor = "'$MONITOR_GAME'" })'
    hyprctl dispatch 'hl.dsp.workspace.move({ workspace = 2, monitor = "'$MONITOR_GAME'" })'
    hyprctl dispatch 'hl.dsp.workspace.move({ workspace = 3, monitor = "'$MONITOR_GAME'" })'
    notify-send "🕹️ Modo Jogo" "Migrado para $MONITOR_GAME (75 Hz)"
fi
