#!/bin/bash

# Detecta quais saídas estão ativas
ACTIVE_OUTPUTS=$(hyprctl monitors -j | jq -r '.[].name')

HDMI1="HDMI-A-1"
HDMI2="HDMI-A-2"

# Se o HDMI1 estiver ativo, troca para o HDMI2
if echo "$ACTIVE_OUTPUTS" | grep -q "$HDMI1"; then
    echo "Trocando para $HDMI2..."
    hyprctl eval 'hl.monitor({ output = "'$HDMI1'", disabled = true })'
    hyprctl eval 'hl.monitor({ output = "'$HDMI2'", mode = "preferred", position = "0x0", scale = 1 })'
    sleep 1

    # Move todas as janelas para o HDMI2
    for wid in $(hyprctl clients -j | jq -r '.[].address'); do
        hyprctl dispatch 'hl.dsp.window.move({ workspace = 1, window = "address:'$wid'" })'
    done

# Caso contrário, faz o oposto
elif echo "$ACTIVE_OUTPUTS" | grep -q "$HDMI2"; then
    echo "Trocando para $HDMI1..."
    hyprctl eval 'hl.monitor({ output = "'$HDMI2'", disabled = true })'
    hyprctl eval 'hl.monitor({ output = "'$HDMI1'", mode = "preferred", position = "0x0", scale = 1 })'
    sleep 1

    # Move todas as janelas para o HDMI1
    for wid in $(hyprctl clients -j | jq -r '.[].address'); do
        hyprctl dispatch 'hl.dsp.window.move({ workspace = 1, window = "address:'$wid'" })'
    done
fi
