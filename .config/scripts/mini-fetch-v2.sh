#!/bin/bash

# mini-fetch v2.2 — minimalista com cores

# Cores
BLUE="\033[1;34m"
NC="\033[0m"  # Sem cor (reset)

# Distro
distro=$(grep -m1 '^NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')

# Host
if command -v hostname >/dev/null 2>&1; then
    host=$(hostname)
else
    host=$(cat /etc/hostname 2>/dev/null || echo "Desconhecido")
fi

# Kernel
kernel=$(uname -r)

# CPU
cpu=$(grep -m1 'model name' /proc/cpuinfo | cut -d':' -f2 | xargs)
cores=$(grep -c '^processor' /proc/cpuinfo)
cpu="$cpu ($cores cores)"

# GPU
gpu=$(lspci | grep -E "VGA|3D" | grep "AMD" | sed -E 's/.*\[AMD\/ATI\] //' | sed -E 's/.*\[Radeon ([^]]+)\].*/Radeon \1/' | head -n1)
gpu=${gpu:-"Desconhecida"}

# RAM
read ram_total ram_used <<<$(free -h | awk '/Mem/ {print $2, $3; exit}')

# Disco
disk_used=$(df -h / | awk 'NR==2 {print $3}')
disk_total=$(df -h / | awk 'NR==2 {print $2}')
disk_perc=$(df -h / | awk 'NR==2 {print $5}')

# Exibição colorida
echo -e "${BLUE}Distro:${NC}  $distro"
echo -e "${BLUE}Host:${NC}    $host"
echo -e "${BLUE}Kernel:${NC}  $kernel"
echo -e "${BLUE}CPU:${NC}     $cpu"
echo -e "${BLUE}GPU:${NC}     $gpu"
echo -e "${BLUE}RAM:${NC}     $ram_used/$ram_total"
echo -e "${BLUE}Disco:${NC}   $disk_used/$disk_total ($disk_perc) on /"
