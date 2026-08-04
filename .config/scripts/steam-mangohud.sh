#!/bin/bash
# Script para rodar Steam com MangoHud
# STEAM_FORCE_DESKTOPUI_SCALING: escala a UI do cliente Steam em 4K
# (com o force_zero_scaling do XWayland, o cliente abre sem escala)

export MANGOHUD=1
export STEAM_FORCE_DESKTOPUI_SCALING=2
exec steam
