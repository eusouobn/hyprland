#!/bin/bash
# Script de reinstalação completa de pacotes no Arch Linux

# Verifica se o script está rodando como root
if [[ $EUID -ne 0 ]]; then
   echo "Execute como root: sudo $0"
   exit 1
fi

# Arquivo de pacotes (gerado pelo backup anterior)
PKG_LIST="$HOME/package_backups/packages.txt"

if [[ ! -f "$PKG_LIST" ]]; then
    echo "Arquivo de pacotes não encontrado em $PKG_LIST"
    exit 1
fi

# 1. Instalar git se não estiver
if ! command -v git >/dev/null 2>&1; then
    echo "Instalando git..."
    pacman -S --noconfirm git
fi

# 2. Ajustar /etc/makepkg.conf para usar N-1 threads
THREADS=$(($(nproc) - 1))
echo "Configurando makepkg para usar $THREADS threads de compilação..."
sed -i "s/^#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$THREADS\"/" /etc/makepkg.conf
sed -i "s/^MAKEFLAGS=\"-j[0-9]\+\"/MAKEFLAGS=\"-j$THREADS\"/" /etc/makepkg.conf

# 3. Instalar yay se não estiver
if ! command -v yay >/dev/null 2>&1; then
    echo "Instalando yay..."
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay || exit
    makepkg -si --noconfirm
fi

# 4. Instalar todos os pacotes da lista
echo "Instalando todos os pacotes listados..."
yay -S --noconfirm - < "$PKG_LIST"

echo "Todos os pacotes foram reinstalados com sucesso!"
