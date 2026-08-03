#!/usr/bin/env bash
#
# Script para coletar informações detalhadas do sistema Linux
# Exibe na tela e grava tudo em um arquivo de log
#

LOGFILE="$HOME/system_info_$(date +%Y-%m-%d_%H-%M-%S).log"

# Função para imprimir título formatado
print_section() {
    echo -e "\n=============================="
    echo "== $1"
    echo "=============================="
}

# Redireciona tudo (stdout e stderr) para a tela e o arquivo
exec > >(tee -a "$LOGFILE") 2>&1

print_section "INFORMAÇÕES GERAIS"
echo "Data e hora: $(date)"
echo "Usuário: $(whoami)"
if command -v hostname &>/dev/null; then
    echo "Hostname: $(hostname)"
else
    echo "Hostname: (comando hostname não encontrado)"
fi
if [ -f /etc/os-release ]; then
    source /etc/os-release
    echo "Distro: $PRETTY_NAME"
else
    echo "Distro: (não foi possível identificar)"
fi
echo "Arquitetura: $(uname -m)"
echo "Kernel: $(uname -r)"
echo "Shell: $SHELL"
echo "Uptime: $(uptime -p 2>/dev/null || cat /proc/uptime)"

print_section "CPU"
if command -v lscpu &>/dev/null; then
    lscpu
else
    echo "lscpu não encontrado"
fi

print_section "MEMÓRIA"
free -h 2>/dev/null || echo "Comando free não encontrado"
echo
grep -E "MemTotal|MemAvailable|SwapTotal|SwapFree" /proc/meminfo

print_section "GPU / DRIVERS"
if command -v lspci &>/dev/null; then
    lspci | grep -E "VGA|3D"
else
    echo "lspci não encontrado"
fi
echo
if command -v glxinfo &>/dev/null; then
    glxinfo | grep -E "OpenGL vendor|OpenGL renderer|OpenGL version|OpenGL core profile version"
else
    echo "glxinfo não encontrado (instale mesa-demos)"
fi
echo
if command -v vulkaninfo &>/dev/null; then
    vulkaninfo | grep -E "apiVersion|driverVersion|deviceName|vendorID" | head -n 20
else
    echo "vulkaninfo não encontrado (instale vulkan-tools)"
fi

print_section "MESA"
if command -v glxinfo &>/dev/null; then
    glxinfo | grep "Mesa"
else
    echo "glxinfo não encontrado"
fi

print_section "PACOTES RELACIONADOS A GRÁFICOS"
if command -v pacman &>/dev/null; then
    pacman -Q | grep -E "mesa|vulkan|amdvlk|nvidia|intel|opencl"
elif command -v apt &>/dev/null; then
    dpkg -l | grep -E "mesa|vulkan|nvidia|intel|amd"
else
    echo "Gerenciador de pacotes não suportado detectado"
fi

print_section "WAYLAND / X11"
echo "Sessão atual: ${XDG_SESSION_TYPE:-Desconhecida}"
echo "Compositor: ${XDG_CURRENT_DESKTOP:-Desconhecido}"
echo "Display: ${DISPLAY:-Nenhum}"

print_section "DISPOSITIVOS PCI"
if command -v lspci &>/dev/null; then
    lspci -nnk | grep -A3 -E "VGA|3D|Display"
else
    echo "lspci não encontrado"
fi

print_section "DISPOSITIVOS USB"
if command -v lsusb &>/dev/null; then
    lsusb
else
    echo "lsusb não encontrado"
fi

print_section "DRIVERS CARREGADOS"
if command -v lsmod &>/dev/null; then
    lsmod | grep -E "amdgpu|i915|nvidia" || echo "Nenhum driver gráfico listado especificamente"
else
    echo "lsmod não encontrado"
fi

print_section "INFORMAÇÕES DE REDE"
if command -v ip &>/dev/null; then
    ip -br addr
else
    echo "Comando ip não encontrado"
fi

print_section "ARMAZENAMENTO"
if command -v lsblk &>/dev/null; then
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINTS,FSTYPE
else
    echo "lsblk não encontrado"
fi
echo
df -hT 2>/dev/null || echo "df não encontrado"

print_section "TEMPERATURAS (se suportado)"
if command -v sensors &>/dev/null; then
    sensors
else
    echo "sensors não instalado (pacote lm_sensors)"
fi

print_section "PROCESSOS RELACIONADOS À GPU"
ps aux | grep -E "Xorg|wayland|gamescope|steam|mangoapp|obs|mesa" | grep -v grep

print_section "FIM DO RELATÓRIO"
echo "Arquivo salvo em: $LOGFILE"
echo "----------------------------------------"
