#!/bin/bash

# Detecta quais saídas estão ativas
ACTIVE_OUTPUTS=$(hyprctl monitors -j | jq -r '.[].name')

HDMI1="HDMI-A-1"
HDMI2="HDMI-A-2"

# Se o HDMI1 estiver ativo, troca para o HDMI2
if echo "$ACTIVE_OUTPUTS" | grep -q "$HDMI1"; then
    echo "Trocando para $HDMI2..."
    hyprctl keyword monitor "$HDMI1,disable"
    hyprctl keyword monitor "$HDMI2,preferred,0x0,1"
    sleep 1

    # Move todas as janelas para o HDMI2
    for wid in $(hyprctl clients -j | jq -r '.[].address'); do
        hyprctl dispatch movetoworkspacesilent "1, address:$wid"
    done

# Caso contrário, faz o oposto
elif echo "$ACTIVE_OUTPUTS" | grep -q "$HDMI2"; then
    echo "Trocando para $HDMI1..."
    hyprctl keyword monitor "$HDMI2,disable"
    hyprctl keyword monitor "$HDMI1,preferred,0x0,1"
    sleep 1

    # Move todas as janelas para o HDMI1
    for wid in $(hyprctl clients -j | jq -r '.[].address'); do
        hyprctl dispatch movetoworkspacesilent "1, address:$wid"
    done
fi
