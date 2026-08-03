#!/usr/bin/env bash
# Script interativo para definir aplicativos padrão globais
# Gwenview (imagens), MPV (vídeos), Audacious (áudios)

MIME_FILE="/usr/share/applications/mimeapps.list"

set_default_app() {
    local app_name="$1"
    local desktop_entry="$2"
    shift 2
    local mimes=("$@")

    echo "🔧 Definindo $app_name como padrão..."

    # Garante que o arquivo global existe
    if [[ ! -f "$MIME_FILE" ]]; then
        echo "🗂️ Criando arquivo global de associações MIME..."
        sudo touch "$MIME_FILE"
    fi

    # Define localmente (para o usuário atual)
    for mime in "${mimes[@]}"; do
        xdg-mime default "$desktop_entry" "$mime"
    done

    # Copia para configuração global
    echo "📁 Atualizando configurações globais em $MIME_FILE ..."
    sudo mkdir -p /usr/share/applications
    sudo cp ~/.config/mimeapps.list "$MIME_FILE"

    echo "✅ $app_name definido como aplicativo padrão global."
    echo
}

set_all_defaults() {
    echo "🚀 Definindo todos os aplicativos padrão (Gwenview, MPV, Audacious)..."
    echo

    set_default_app "Gwenview" "org.kde.gwenview.desktop" \
        "image/jpeg" "image/png" "image/gif" "image/webp" \
        "image/bmp" "image/tiff" "image/x-xpixmap"

    set_default_app "MPV" "mpv.desktop" \
        "video/mp4" "video/x-matroska" "video/webm" \
        "video/x-msvideo" "video/quicktime" "video/x-flv" \
        "video/mpeg" "video/3gpp" "video/x-ms-wmv"

    set_default_app "Audacious" "audacious.desktop" \
        "audio/mpeg" "audio/mp4" "audio/x-wav" "audio/flac" \
        "audio/ogg" "audio/x-vorbis+ogg" "audio/x-ms-wma" \
        "audio/x-aiff" "audio/x-m4a" "audio/webm"

    echo "🎉 Todos os aplicativos padrão foram definidos com sucesso!"
    echo
}

show_menu() {
    echo "=============================="
    echo " Definir Aplicativo Padrão"
    echo "=============================="
    echo "1 - Gwenview (Imagens)"
    echo "2 - MPV (Vídeos)"
    echo "3 - Audacious (Áudio)"
    echo "4 - Definir todos"
    echo "5 - Sair"
    echo
    read -rp "Escolha uma opção: " choice
    echo

    case "$choice" in
        1)
            set_default_app "Gwenview" "org.kde.gwenview.desktop" \
                "image/jpeg" "image/png" "image/gif" "image/webp" \
                "image/bmp" "image/tiff" "image/x-xpixmap"
            ;;
        2)
            set_default_app "MPV" "mpv.desktop" \
                "video/mp4" "video/x-matroska" "video/webm" \
                "video/x-msvideo" "video/quicktime" "video/x-flv" \
                "video/mpeg" "video/3gpp" "video/x-ms-wmv"
            ;;
        3)
            set_default_app "Audacious" "audacious.desktop" \
                "audio/mpeg" "audio/mp4" "audio/x-wav" "audio/flac" \
                "audio/ogg" "audio/x-vorbis+ogg" "audio/x-ms-wma" \
                "audio/x-aiff" "audio/x-m4a" "audio/webm"
            ;;
        4)
            set_all_defaults
            ;;
        5)
            echo "👋 Saindo..."
            exit 0
            ;;
        *)
            echo "❌ Opção inválida."
            ;;
    esac
}

# Loop principal
while true; do
    show_menu
done
