#!/usr/bin/env bash
# Script para escolher o kernel padrão no systemd-boot
# Local: ~/.scripts/set-default-kernel.sh

# Força sudo logo no início (mesmo se chamado via caminho relativo)
if [[ $EUID -ne 0 ]]; then
    echo "Este script precisa ser executado como root."
    SCRIPT_PATH="$(realpath "$0")"
    exec sudo bash "$SCRIPT_PATH" "$@"
fi

BOOTDIR="/boot"
LOADER_CONF="$BOOTDIR/loader/loader.conf"
ENTRYDIR="$BOOTDIR/loader/entries"

echo "==> Defina o Kernel padrão:"
echo

mapfile -t entries < <(ls "$ENTRYDIR"/*.conf 2>/dev/null | xargs -n1 basename)

if [ ${#entries[@]} -eq 0 ]; then
    echo "Nenhuma entrada encontrada em $ENTRYDIR."
    exit 1
fi

# Lista as entradas com numeração
for i in "${!entries[@]}"; do
    echo "$((i+1)) - ${entries[$i]%.conf}"
done

echo
read -p "Pressione o número correspondente (ou 0 para cancelar): " choice

if [[ "$choice" == "0" ]]; then
    echo "Operação cancelada."
    exit 0
fi

if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#entries[@]}" ]; then
    echo "Opção inválida."
    exit 1
fi

selected="${entries[$((choice-1))]}"

# Atualiza o loader.conf
{
    echo "default ${selected}"
    echo "timeout 3"
} > "$LOADER_CONF"

echo
echo "✅ Kernel padrão definido para: ${selected%.conf}"
