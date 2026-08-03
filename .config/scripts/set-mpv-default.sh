#!/usr/bin/env bash
# Define o MPV como reprodutor padrão de vídeos (globalmente)

DESKTOP_ENTRY="mpv.desktop"
MIME_FILE="/usr/share/applications/mimeapps.list"

MIMES=(
  "video/mp4"
  "video/x-matroska"
  "video/webm"
  "video/x-msvideo"
  "video/quicktime"
  "video/x-flv"
  "video/mpeg"
  "video/3gpp"
  "video/x-ms-wmv"
)

echo "🎬 Definindo MPV como padrão para arquivos de vídeo..."

if [[ ! -f "$MIME_FILE" ]]; then
  echo "🗂️ Criando arquivo global de associações MIME..."
  sudo touch "$MIME_FILE"
fi

# Define localmente para garantir consistência
for mime in "${MIMES[@]}"; do
  xdg-mime default "$DESKTOP_ENTRY" "$mime"
done

# Copia para configuração global
echo "📁 Atualizando configurações globais em $MIME_FILE ..."
sudo mkdir -p /usr/share/applications
sudo cp ~/.config/mimeapps.list "$MIME_FILE"

echo "✅ MPV definido como reprodutor padrão de vídeos para todos os usuários."
