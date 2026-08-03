#!/usr/bin/env bash

BLUE="\033[1;34m"
NC="\033[0m"

# Logo maior (8 linhas reais, mais imponente)
logo_lines=(
"                  "
"        /\\        "
"       /  \\       "
"      / /\\ \\      "
"     /      \\     "
"    /  /\\    \\    "
"   /__/  \\____\\   "
"                  "
)

# ======= Infos =======
labels=()
values=()

labels+=("Distro:"); values+=("$(grep -m1 '^NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')")
labels+=("Host:"); values+=("$(hostname 2>/dev/null || cat /etc/hostname 2>/dev/null || echo Desconhecido)")
labels+=("Kernel:"); values+=("$(uname -r)")
cpu_model="$(grep -m1 'model name' /proc/cpuinfo | cut -d':' -f2 | xargs)"; cpu_cores="$(grep -c '^processor' /proc/cpuinfo)"; labels+=("CPU:"); values+=("$cpu_model ($cpu_cores cores)")
gpu_value="$(lspci | grep -E 'VGA|3D' | grep 'AMD' | sed -E 's/.*\[AMD\/ATI\] //' | sed -E 's/.*\[Radeon ([^]]+)\].*/Radeon \1/' | head -n1)"; gpu_value="${gpu_value:-Desconhecida}"; labels+=("GPU:"); values+=("$gpu_value")
read ram_total ram_used <<<$(free -h | awk '/Mem/ {print $2,$3;exit}'); labels+=("RAM:"); values+=("$ram_used/$ram_total")
read disk_root_total disk_root_used disk_root_perc <<<$(df -h / | awk 'NR==2 {print $2,$3,$5}'); labels+=("/:"); values+=("$disk_root_used/$disk_root_total ($disk_root_perc)")
if df -h /home >/dev/null 2>&1; then
    read disk_home_total disk_home_used disk_home_perc <<<$(df -h /home | awk 'NR==2 {print $2,$3,$5}')
else
    disk_home_total="0B"; disk_home_used="0B"; disk_home_perc="0%"
fi
labels+=("/home:"); values+=("$disk_home_used/$disk_home_total ($disk_home_perc)")

logo_width=18

# Espaço topo
echo

# Impressão alinhada (logo + infos)
for i in "${!labels[@]}"; do
    logo_part="${logo_lines[i]:-}" # linha de logo ou vazia
    printf "${BLUE}%-${logo_width}s %-8s${NC} %s\n" "$logo_part" "${labels[i]}" "${values[i]}"
done

# Espaço final
echo
