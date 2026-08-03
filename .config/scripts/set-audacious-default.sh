#!/usr/bin/env bash
# Define o Audacious como reprodutor padrão de áudio (globalmente)

DESKTOP_ENTRY="audacious.desktop"
MIME_FILE="/usr/share/applications/mimeapps.list"

MIMES=(
  "audio/mpeg"
  "audio/mp4"
  "audio/x-wav"
  "audio/flac"
  "audio/ogg"
  "audio/x-vorbis+ogg"
  "audio/x-ms-wma"
  "audio/x-aiff"
  "audio/x-m4a"
  "audio/webm"
)

echo "🎵 Definindo Audacious como padrão para arquivos de áudio..."

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

echo "✅ Audacious definido como reprodutor padrão de áudio para todos os usuários."
