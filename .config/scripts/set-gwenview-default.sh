#!/usr/bin/env bash
# Define o Gwenview como visualizador padrão de imagens (globalmente)

# Caminho do desktop file
DESKTOP_ENTRY="org.kde.gwenview.desktop"
MIME_FILE="/usr/share/applications/mimeapps.list"

# Lista de tipos MIME de imagens
MIMES=(
  "image/jpeg"
  "image/png"
  "image/gif"
  "image/webp"
  "image/bmp"
  "image/tiff"
  "image/x-xpixmap"
)

echo "🔧 Definindo Gwenview como padrão para arquivos de imagem..."

# Garante que o arquivo existe
if [[ ! -f "$MIME_FILE" ]]; then
  echo "🗂️ Criando arquivo global de associações MIME..."
  sudo touch "$MIME_FILE"
fi

# Aplica associações localmente (para garantir consistência)
for mime in "${MIMES[@]}"; do
  xdg-mime default "$DESKTOP_ENTRY" "$mime"
done

# Copia para configuração global
echo "📁 Atualizando configurações globais em $MIME_FILE ..."
sudo mkdir -p /usr/share/applications
sudo cp ~/.config/mimeapps.list "$MIME_FILE"

echo "✅ Gwenview definido como visualizador padrão de imagens para todos os usuários."
