#!/bin/bash
# Script de instalação de pacotes por ambiente de desktop

# Verifica se está rodando como root
if [[ $EUID -ne 0 ]]; then
   echo "Execute como root: sudo $0"
   exit 1
fi

# Detectar DE
DE=$(echo $XDG_CURRENT_DESKTOP | tr '[:upper:]' '[:lower:]')

echo "Detectado ambiente de desktop: $DE"

if [[ "$DE" == *"xfce"* ]]; then
    echo "Instalando pacotes para XFCE..."
    pacman -S --noconfirm galculator xfce4-screenshooter ristretto mousepad audacious \
        xarchiver file-roller tar gzip bzip2 zip unzip unrar p7zip thunar-archive-plugin \
        cups gtk3-print-backends system-config-printer hplip xsane python-pyqt5
elif [[ "$DE" == *"kde"* ]] || [[ "$DE" == *"hyprland"* ]]; then
    echo "Instalando pacotes para KDE/Hyprland..."
    pacman -S --noconfirm gwenview kcalc spectacle audacious mpv gimp kwrite kdialog ark \
        tar gzip bzip2 zip unzip unrar p7zip print-manager cups system-config-printer hplip python-pyqt5
else
    echo "Ambiente de desktop não detectado ou não suportado. Abortando."
    exit 1
fi

# Habilitar serviços de impressão
echo "Habilitando serviço de impressão CUPS..."
systemctl enable cups
systemctl start cups

echo "Instalação concluída com sucesso!"
