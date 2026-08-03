#!/bin/bash
# Script para gerar lista de pacotes instalados no Arch Linux
# Salva em um arquivo timestampado para backup ou reinstalação

# Diretório onde salvar os backups
BACKUP_DIR="$HOME/package_backups"
mkdir -p "$BACKUP_DIR"

# Arquivo de saída
DATE=$(date +%Y-%m-%d_%H-%M-%S)
PKG_FILE="$BACKUP_DIR/packages_$DATE.txt"

echo "Gerando lista de pacotes instalados..."

# 1. Pacotes oficiais (repositórios)
echo "Pacotes oficiais:" > "$PKG_FILE"
pacman -Qqe >> "$PKG_FILE"

# 2. Pacotes AUR (instalados manualmente ou via AUR helper como yay)
if command -v yay >/dev/null 2>&1; then
    echo -e "\nPacotes AUR:" >> "$PKG_FILE"
    yay -Qqe | while read pkg; do
        # Verifica se o pacote está no repositório oficial, caso contrário é AUR
        if ! pacman -Si "$pkg" >/dev/null 2>&1; then
            echo "$pkg" >> "$PKG_FILE"
        fi
    done
else
    echo -e "\nAviso: yay não encontrado, pacotes AUR não serão listados." >> "$PKG_FILE"
fi

echo "Lista completa salva em: $PKG_FILE"
