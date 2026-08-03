#!/usr/bin/env bash
# mini-fetch.sh - Minimal system info (Distro, Host, Kernel, CPU, GPU, RAM, Disco)

# --- helpers ---
green="\033[1;32m"
reset="\033[0m"

# --- Distro ---
if [ -r /etc/os-release ]; then
  . /etc/os-release
  DISTRO="${PRETTY_NAME:-$NAME}"
else
  DISTRO="$(uname -s)"
fi

# --- Host ---
HOST="$(hostnamectl --static 2>/dev/null || hostname)"

# --- Kernel ---
KERNEL="$(uname -r)"

# --- CPU ---
CPU_MODEL=""
if command -v lscpu >/dev/null 2>&1; then
  CPU_MODEL="$(lscpu | grep -m1 'Model name:' | cut -d: -f2 | sed 's/^[ \t]*//')"
  [ -z "$CPU_MODEL" ] && CPU_MODEL="$(lscpu | grep -m1 '^Model:' | cut -d: -f2 | sed 's/^[ \t]*//')"
  [ -z "$CPU_MODEL" ] && CPU_MODEL="$(lscpu | grep -m1 'Architecture:' | cut -d: -f2 | sed 's/^[ \t]*//')"
fi
if [ -z "$CPU_MODEL" ] && [ -r /proc/cpuinfo ]; then
  CPU_MODEL="$(awk -F: '/model name|Processor|Hardware/ {gsub(/^[ \t]+/, "", $2); print $2; exit}' /proc/cpuinfo)"
fi
CPU_MODEL="${CPU_MODEL:-Desconhecido}"
CPU_CORES="$(nproc 2>/dev/null || grep -c ^processor /proc/cpuinfo)"
CPU="${CPU_MODEL} (${CPU_CORES:-?} cores)"

# --- GPU ---
if command -v lspci >/dev/null 2>&1; then
  GPU="$(lspci | grep -E 'VGA|3D' | head -n1 | cut -d':' -f3- | sed 's/^[ \t]*//')"
else
  GPU="N/A"
fi

# --- RAM ---
if [ -r /proc/meminfo ]; then
  total_kb=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
  avail_kb=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
  if [ -n "$total_kb" ] && [ -n "$avail_kb" ]; then
    used_kb=$((total_kb - avail_kb))
    used_gb=$(awk -v u="$used_kb" 'BEGIN{printf "%.1f", u/1024/1024}')
    total_gb=$(awk -v t="$total_kb" 'BEGIN{printf "%.1f", t/1024/1024}')
    RAM="${used_gb}G/${total_gb}G"
  else
    RAM="N/A"
  fi
else
  RAM="N/A"
fi

# --- Disco ---
DISK="$(df -h --output=used,size,pcent,target / | awk 'NR==2 {print $1 "/" $2 " (" $3 ") on " $4}')"

# --- Print ---
printf "${green}Distro:${reset}  %s\n" "$DISTRO"
printf "${green}Host:${reset}    %s\n" "$HOST"
printf "${green}Kernel:${reset}  %s\n" "$KERNEL"
printf "${green}CPU:${reset}     %s\n" "$CPU"
printf "${green}GPU:${reset}     %s\n" "$GPU"
printf "${green}RAM:${reset}     %s\n" "$RAM"
printf "${green}Disco:${reset}   %s\n" "$DISK"
