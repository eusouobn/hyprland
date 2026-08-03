#!/bin/bash

DIR="$HOME/Imagens/Screenshots"
mkdir -p "$DIR"

FILE="$DIR/Screenshot-$(date +'%Y-%m-%d_%H-%M-%S').png"

# Escolha o modo de captura
MODE=$(printf "1️⃣ Tela inteira\n2️⃣ Janela ativa\n3️⃣ Selecionar área" | \
       wofi --dmenu --prompt "Modo de captura:")

case "$MODE" in
    "1️⃣ Tela inteira")
        grim - | tee "$FILE" >(wl-copy) >/dev/null
        ;;
    "2️⃣ Janela ativa")
        # Captura apenas a janela ativa via hyprctl
        GEOM=$(hyprctl activewindow -j | jq -r '.at[0], .at[1], .size[0], .size[1]' | tr '\n' ' ')
        grim -g "$GEOM" - | tee "$FILE" >(wl-copy) >/dev/null
        ;;
    "3️⃣ Selecionar área")
        # Usa slurp para selecionar manualmente
        AREA=$(slurp)
        [ -n "$AREA" ] && grim -g "$AREA" - | tee "$FILE" >(wl-copy) >/dev/null
        ;;
    *)
        exit 0
        ;;
esac

# Som do obturador
ffplay -nodisp -autoexit /usr/share/sounds/freedesktop/stereo/camera-shutter.oga >/dev/null 2>&1

# Notificação
# notify-send "Screenshot" "Imagem salva e copiada para a área de transferência!"

