#!/usr/bin/env bash
# Atualizador automático para systemd-boot
# Local: ~/.scripts/update-systemd-boot.sh

# Solicita sudo no início
if [[ $EUID -ne 0 ]]; then
    echo "Este script precisa ser executado como root."
    exec sudo bash "$0" "$@"
fi

set -e

BOOTDIR="/boot"
ENTRYDIR="$BOOTDIR/loader/entries"
ROOT_UUID=$(blkid -s UUID -o value "$(findmnt / -no SOURCE)")

echo "==> Atualizando systemd-boot..."
bootctl update

echo "==> Limpando entradas antigas..."
rm -f "$ENTRYDIR"/*.conf

echo "==> Gerando novas entradas de kernel..."
for kernel in "$BOOTDIR"/vmlinuz-*; do
    [ -f "$kernel" ] || continue

    base=$(basename "$kernel" | sed 's/^vmlinuz-//')
    initramfs="$BOOTDIR/initramfs-${base}.img"
    fallback="$BOOTDIR/initramfs-${base}-fallback.img"
    entry="$ENTRYDIR/${base}.conf"

    echo " -> Criando: ${base}.conf"

    cat > "$entry" <<EOF
title   Arch Linux (${base})
linux   /vmlinuz-${base}
initrd  /initramfs-${base}.img
EOF

    # Adiciona fallback se existir
    if [ -f "$fallback" ]; then
        echo "initrd  /initramfs-${base}-fallback.img" >> "$entry"
    fi

    cat >> "$entry" <<EOF
options root=UUID=${ROOT_UUID} rw loglevel=7
EOF
done

# Define entrada padrão (último kernel processado)
if [ -n "$base" ]; then
    echo "default ${base}.conf" > "$BOOTDIR/loader/loader.conf"
    echo "timeout 3" >> "$BOOTDIR/loader/loader.conf"
fi

echo "==> Concluído com sucesso!"
