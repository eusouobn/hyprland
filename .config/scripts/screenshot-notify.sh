#!/bin/bash

F="$HOME/Imagens/Screenshots/Screenshot-$(date +'%Y-%m-%d_%H-%M-%S').png"

# Captura, salva e copia
grim - | tee "$F" >(wl-copy) >/dev/null

# Som do obturador
ffplay -nodisp -autoexit /usr/share/sounds/freedesktop/stereo/camera-shutter.oga >/dev/null 2>&1

# Notificação
notify-send "Screenshot" "Imagem salva e copiada para a área de transferência!"
