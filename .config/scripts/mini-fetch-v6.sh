#!/usr/bin/env bash

# mini-fetch v3.4 — logo Arch + labels azuis + DE/WM + discos / e /home + espaços topo/baixo

BLUE="\033[1;34m"
NC="\033[0m"

# ===== Detecta DE/WM =====
if [ -n "$XDG_CURRENT_DESKTOP" ]; then
    WM="$XDG_CURRENT_DESKTOP"
elif pgrep -x hyprland >/dev/null 2>&1; then
    WM="Hyprland"
elif pgrep -x sway >/dev/null 2>&1; then
    WM="Sway"
elif pgrep -x i3 >/dev/null 2>&1; then
    WM="i3"
else
    WM="Unknown"
fi

# ===== Logo Arch (V3) =====
logo_lines=(
"       /\\"
"      /  \\"
"     /\\   \\"
"    /      \\"
"   /  /\\    \\"
"  /__/  \\____\\"
)

# ===== Infos =======
distro_label="Distro:"
distro_value="$(grep -m1 '^NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')"
distro_value="$distro_value ($WM)"

host_label="Host:"
host_value="$(hostname 2>/dev/null || cat /etc/hostname 2>/dev/null || echo Desconhecido)"

kernel_label="Kernel:"
kernel_value="$(uname -r)"

cpu_label="CPU:"
cpu_model="$(grep -m1 'model name' /proc/cpuinfo | cut -d':' -f2 | xargs | sed -E 's/[0-9]+-Core Processor//')"
cpu_value="$cpu_model"

gpu_label="GPU:"
gpu_value="$(lspci | grep -E 'VGA|3D' | grep 'AMD' | sed -E 's/.*\[AMD\/ATI\] //' | sed -E 's/.*\[Radeon ([^]]+)\].*/Radeon \1/' | head -n1)"
gpu_value="${gpu_value:-Desconhecida}"

ram_label="RAM:"
read ram_total ram_used <<<$(free -h | awk '/Mem/ {print $2,$3; exit}')
ram_value="$ram_used/$ram_total"

# Disco /
disk_root_label="/:"
read disk_root_total disk_root_used disk_root_perc <<<$(df -h / | awk 'NR==2 {print $2,$3,$5}')
disk_root_value="$disk_root_used/$disk_root_total ($disk_root_perc)"

# Disco /home
disk_home_label="/home:"
if df -h /home >/dev/null 2>&1; then
    read disk_home_total disk_home_used disk_home_perc <<<$(df -h /home | awk 'NR==2 {print $2,$3,$5}')
else
    disk_home_total="0B"; disk_home_used="0B"; disk_home_perc="0%"
fi
disk_home_value="$disk_home_used/$disk_home_total ($disk_home_perc)"

labels=("$distro_label" "$host_label" "$kernel_label" "$cpu_label" "$gpu_label" "$ram_label" "$disk_root_label" "$disk_home_label")
values=("$distro_value" "$host_value" "$kernel_value" "$cpu_value" "$gpu_value" "$ram_value" "$disk_root_value" "$disk_home_value")

logo_width=14

# Espaço no topo
echo
echo

# Impressão linha a linha
for i in "${!labels[@]}"; do
    logo_part="${logo_lines[i]:-}"  # pega linha de logo ou vazio
    label="${labels[i]:-}"
    value="${values[i]:-}"
    printf "${BLUE}%-${logo_width}s %-8s${NC} %s\n" "$logo_part" "$label" "$value"
done

# Espaço no final
echo
echo
