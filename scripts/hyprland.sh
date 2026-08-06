#!/usr/bin/env bash

# ──────────────────────────────────────────────
# Forçar execução com bash (antes do set -euo pipefail)
# ──────────────────────────────────────────────
if [ -z "$BASH_VERSION" ]; then
  echo -e "\033[0;31m✘\033[0m Este script precisa ser executado com bash, não com sh."
  echo "  Use: bash hyprland.sh"
  exit 1
fi

set -euo pipefail

# ──────────────────────────────────────────────
# Cores e funções
# ──────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'
CYAN='\033[0;36m'; MAG='\033[0;35m'; BOLD='\033[1m'; NC='\033[0m'

step()  {
  echo ""
  echo -e "  ${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "  ${CYAN}┃${NC} ${MAG}★${NC} ${BOLD}$1${NC}"
  echo -e "  ${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}
info()  { echo -e "  ${CYAN}→${NC} $1"; }
ok()    { echo -e "  ${GREEN}✔${NC} $1"; }
warn()  { echo -e "  ${YELLOW}⚠${NC} $1"; }
err()   { echo -e "  ${RED}✘${NC} $1"; }

run() {
  info "$1"
  shift
  "$@"
  echo -e "  ${GREEN}✔${NC} concluído"
}

quote() {
  local quotes=(
    "O terminal é o melhor amigo do admin. — ditado popular"
    "Se não quebrou, você não mexeu o suficiente. — Lei de Murphy"
    "Linux: porque um terminal é mais leve que 5 cliques."
    "Arch btw. — todo usuário Arch"
    "Wayland é o futuro. E ele chegou."
    "Hyprland: o compositor que ama animações e trava tudo no primeiro dia."
    "Leve, estável e configurável. Quem precisa de mais?"
    "Pacman -Syu resolve. Sempre."
    "RTFM: a documentação é sua melhor amiga."
    "Sudo faz tudo. Inclusive café. — quase."
    "AUR: porque no AUR tem de tudo, até alma gêmea."
    "Yay — porque compilar na mão é coisa do passado."
    "Tema escuro é mais que preferência, é estilo de vida."
  )
  echo -e "  ${YELLOW}💬${NC} ${quotes[$RANDOM % ${#quotes[@]}]}"
}

banner() {
  echo ""
  echo -e "  ${RED}██╗${GREEN}     ${YELLOW}██╗${BLUE}██╗${MAG} ██████╗ ${RED}██╗${GREEN}  ${YELLOW}██╗${BLUE} ██████╗ ${MAG}██████╗ "
  echo -e "  ${RED}██║${GREEN}     ${YELLOW}██║${BLUE}██║${MAG}██╔════╝ ${RED}██║${GREEN}  ${YELLOW}██║${BLUE}██╔═══██╗${MAG}██╔══██╗"
  echo -e "  ${RED}██║${GREEN} ██╗ ${YELLOW}██║${BLUE}██║${MAG}██║      ${RED}██║${GREEN}  ${YELLOW}██║${BLUE}██║   ██║${MAG}██████╔╝"
  echo -e "  ${RED}██║${GREEN} ██║ ${YELLOW}██║${BLUE}██║${MAG}██║      ${RED}██║${GREEN}  ${YELLOW}██║${BLUE}██║   ██║${MAG}██╔══██╗"
  echo -e "  ${RED}██║${GREEN}██╔╝ ${YELLOW}██║${BLUE}██║${MAG}╚██████╗ ${RED}██║${GREEN}  ${YELLOW}██║${BLUE}╚██████╔╝${MAG}██████╔╝"
  echo -e "  ${RED}╚═╝${GREEN}╚═╝  ${YELLOW}╚═╝${BLUE}╚═╝${MAG} ╚═════╝ ${RED}╚═╝${GREEN}  ${YELLOW}╚═╝${BLUE} ╚═════╝ ${MAG}╚═════╝ "
  echo -e "${NC}"
  echo -e "  ${CYAN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
  echo -e "  ${CYAN}▓${NC}           ${BOLD}Hyprland + Waybar${NC}            ${CYAN}▓${NC}"
  echo -e "  ${CYAN}▓${NC}     ${YELLOW}Instalação Completa — Arch Linux${NC}    ${CYAN}▓${NC}"
  echo -e "  ${CYAN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
  echo -e "  ${MAG}✦${NC}  ${BOLD}By eusouobn${NC}  ${MAG}✦${NC}"
  echo ""
  quote
  echo ""
}

# ──────────────────────────────────────────────
# Verificação: não rodar como root
# ──────────────────────────────────────────────
if [ "$(id -u)" -eq 0 ]; then
  err "Não rode este script como root — ele configura o seu usuário."
  exit 1
fi

banner

# ──────────────────────────────────────────────
# Aviso
# ──────────────────────────────────────────────
echo -e "  ${YELLOW}⚠${NC} Este script irá transformar seu Arch recém-instalado"
echo -e "     em um ambiente Hyprland + Waybar completo."
echo -e "  ${YELLOW}⚠${NC} Certifique-se de estar conectado à internet."
echo ""
echo -n "  ${CYAN}⌨${NC} Pressione ENTER para iniciar a instalação... "
read -r
echo ""

# ──────────────────────────────────────────────
# Verificar sudo
# ──────────────────────────────────────────────
if ! command -v sudo &>/dev/null; then
  echo -e "\033[0;31m✘\033[0m 'sudo' não está instalado."
  echo "  Entre como root e instale: pacman -S sudo"
  echo "  Depois configure: echo \"$USER ALL=(ALL) ALL\" >> /etc/sudoers"
  exit 1
fi

info "Verificando acesso sudo... (digite sua senha se solicitado)"
if ! sudo -v; then
  echo -e "\033[0;31m✘\033[0m Você não tem permissão sudo."
  echo "  Entre como root e configure: echo \"$USER ALL=(ALL) ALL\" >> /etc/sudoers"
  exit 1
fi
ok "Acesso sudo confirmado"

# ──────────────────────────────────────────────
# 1. Detectar pendrive com configs
# ──────────────────────────────────────────────
step "🔍 Procurando backup em pendrive..."

PENDRIVE=""
for mount in /run/media/"$USER"/* /mnt/* /media/*; do
  [ -d "$mount" ] && [ -f "$mount/hyprland.tar.gz" ] && PENDRIVE="$mount" && break
done

if [ -n "$PENDRIVE" ]; then
  info "Pendrive detectado em: $PENDRIVE"
else
  warn "Nenhum pendrive com hyprland.tar.gz encontrado."
  warn "Suas configs serão restauradas do git (se disponível)."
fi
quote

# ──────────────────────────────────────────────
# 2. Otimizar compilação + ferramentas básicas
# ──────────────────────────────────────────────
step "⚙️ Otimizando sistema para compilação..."

run "Sincronizando bancos e instalando nano, git..." sudo pacman -Sy --needed --noconfirm nano git

if ! sudo pacman -Qi base-devel &>/dev/null; then
  run "Instalando base-devel..." sudo pacman -S --needed --noconfirm base-devel
fi

CORES=$(nproc)
MAKEFLAGS="-j$((CORES + 1))"
if grep -q "^#MAKEFLAGS" /etc/makepkg.conf 2>/dev/null; then
  sudo sed -i "s/^#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"$MAKEFLAGS\"/" /etc/makepkg.conf
  ok "MAKEFLAGS ajustado para $MAKEFLAGS ($CORES núcleos + 1)"
elif ! grep -q "^MAKEFLAGS" /etc/makepkg.conf 2>/dev/null; then
  echo "MAKEFLAGS=\"$MAKEFLAGS\"" | sudo tee -a /etc/makepkg.conf > /dev/null
  ok "MAKEFLAGS definido como $MAKEFLAGS"
else
  info "MAKEFLAGS já configurado"
fi

if ! command -v yay &>/dev/null; then
  info "Preparando AUR helper (yay)..."
  rm -rf /tmp/yay-bin
  git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
  (cd /tmp/yay-bin && makepkg -si --noconfirm)
  rm -rf /tmp/yay-bin
  ok "yay instalado com sucesso"
fi
quote

# ──────────────────────────────────────────────
# 3. Pacotes oficiais
# ──────────────────────────────────────────────
OFFICIAL_PACKAGES=(
  # ── Compositor / WM ──
  hyprland sddm

  # ── Barra / utilidades Wayland ──
  waybar grim slurp wl-clipboard swaync awww

  # ── Launcher / visual ──
  rofi nwg-drawer nwg-look wofi

  # ── Portais xdg ──
  xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk xdg-desktop-portal-wlr

  # ── Apps KDE/GNOME ──
  dolphin dolphin-plugins kde-cli-tools kio kio-extras kio-fuse kservice kfilemetadata kate
  konsole kcalc gwenview ark ksnip papers loupe gnome-calculator gnome-disk-utility
  gnome-text-editor gnome-calendar plasma-workspace

  # ── Terminal / shell ──
  kitty btop

  # ── Temas / ícones ──
  papirus-icon-theme orchis-theme adw-gtk-theme breeze breeze5 breeze-icons breeze-gtk

  # ── Áudio / Bluetooth ──
  pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber
  alsa-utils pavucontrol network-manager-applet blueman

  # ── Login / polkit ──
  polkit-gnome polkit-kde-agent

  # ── Utilitários ──
  unrar unrar-free unzip pacman-contrib xdg-user-dirs xdg-user-dirs-gtk
  archlinux-xdg-menu ffmpeg ffmpegthumbs ffmpegthumbnailer
  swayidle xorg-xwayland

  # ── Gaming ──
  mangohud lib32-mangohud
)

step "📦 Instalando pacotes oficiais..."
info "${#OFFICIAL_PACKAGES[@]} pacotes — isso pode levar alguns minutos..."
info "Hyprland, Waybar, Dolphin, Firefox, áudio, Bluetooth, ferramentas..."
echo ""

sudo pacman -S --needed --noconfirm "${OFFICIAL_PACKAGES[@]}"
echo ""
ok "Pacotes oficiais instalados"
quote

# ──────────────────────────────────────────────
# 3b. Pacotes AUR
# ──────────────────────────────────────────────
AUR_PACKAGES=(
  clipman
  waypaper
  swaylock-effects
  wlogout
  ttf-ms-fonts
  grimblast-git
  oh-my-posh-bin
  protonup-qt-bin
  qt5ct-kde
  qt6ct-kde
)

step "🌟 Instalando pacotes AUR..."
info "grimblast (screenshot), oh-my-posh (prompt), protonup-qt, qt5ct/qt6ct KDE..."
echo ""

if ! command -v yay &>/dev/null; then
  warn "yay não encontrado — instalando..."
  rm -rf /tmp/yay-bin
  git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
  (cd /tmp/yay-bin && makepkg -si --noconfirm)
  rm -rf /tmp/yay-bin
fi

yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"
echo ""
ok "Pacotes AUR instalados"
quote

# ──────────────────────────────────────────────
# 4. Nerd Fonts + fontes
# ──────────────────────────────────────────────
step "🔤 Instalando Nerd Fonts e fontes..."
info "FiraCode Nerd, JetBrains Mono Nerd, Noto, Font Awesome..."
echo ""

sudo pacman -S --needed --noconfirm \
  ttf-font-awesome noto-fonts noto-fonts-emoji noto-fonts-extra \
  ttf-firacode-nerd ttf-jetbrains-mono-nerd

run "Atualizando cache de fontes..." sudo fc-cache -f
ok "Fontes instaladas — seu terminal nunca mais será o mesmo"
quote

# ──────────────────────────────────────────────
# 4b. Drivers AMD / GPU
# ──────────────────────────────────────────────
step "🎮 Instalando drivers de vídeo..."

if lspci | grep -qi "vga\|3d\|display" | grep -qi "amd\|radeon" || lspci | grep -qiE "amd|radeon"; then
  info "GPU AMD detectada — instalando mesa + vulkan-radeon..."
  sudo pacman -S --needed --noconfirm \
    mesa lib32-mesa mesa-utils vulkan-radeon lib32-vulkan-radeon \
    llvm lib32-llvm vulkan-tools xf86-video-amdgpu
  ok "Drivers AMD instalados"
elif lspci | grep -qi nvidia; then
  info "GPU NVIDIA detectada — instalando nvidia-open-dkms..."
  sudo pacman -S --needed --noconfirm nvidia-open-dkms nvidia-utils lib32-nvidia-utils
  sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 nvidia_drm.modeset=1 nvidia_drm.fbdev=1"/' /etc/default/grub 2>/dev/null || true
  sudo grub-mkconfig -o /boot/grub/grub.cfg 2>/dev/null || true
  ok "Drivers NVIDIA instalados + kernel params"
elif lspci | grep -qi intel; then
  info "GPU Intel detectada — instalando vulkan-intel..."
  sudo pacman -S --needed --noconfirm vulkan-intel mesa lib32-mesa
  ok "Drivers Intel instalados"
else
  warn "GPU não reconhecida — instalando mesa genérico"
  sudo pacman -S --needed --noconfirm mesa
fi
quote

# ──────────────────────────────────────────────
# 5. Verificar instalação do Hyprland
# ──────────────────────────────────────────────
step "🔍 Verificando instalação do Hyprland..."

if command -v Hyprland &>/dev/null; then
  ok "Hyprland detectado: $(Hyprland --version 2>/dev/null | head -1 || echo 'versão desconhecida')"
else
  err "Hyprland não encontrado no PATH."
  info "Instale manualmente: sudo pacman -S hyprland"
fi
quote

# ──────────────────────────────────────────────
# 6. Clonar dotfiles do GitHub (sempre sobrescrever)
# ──────────────────────────────────────────────
step "📥 Baixando dotfiles do GitHub..."
info "De https://github.com/eusouobn/hyprland.git"
echo ""

# Pendrive tem prioridade sobre o git
if [ -n "$PENDRIVE" ]; then
  rm -rf /tmp/hyprland-dotfiles
  mkdir -p /tmp/hyprland-dotfiles
  tar -xzf "$PENDRIVE/hyprland.tar.gz" -C /tmp/hyprland-dotfiles
  ok "Configs restauradas do pendrive ($PENDRIVE)"
else
  rm -rf /tmp/hyprland-dotfiles
  git clone https://github.com/eusouobn/hyprland.git /tmp/hyprland-dotfiles
  ok "Dotfiles baixados do GitHub!"
fi

mkdir -p "$HOME/.config"
cp -r /tmp/hyprland-dotfiles/.config/* "$HOME/.config/"

# Shell
for f in .bashrc .bash_profile .gitconfig; do
  [ -f "/tmp/hyprland-dotfiles/$f" ] && cp "/tmp/hyprland-dotfiles/$f" "$HOME/$f"
done

# Tornar scripts executáveis
chmod +x "$HOME/.config/scripts/"*.sh 2>/dev/null || true
chmod +x "$HOME/.config/hypr/"*.sh 2>/dev/null || true
ok "Scripts tornados executáveis"

# Menus KDE — sem applications.menu o "Abrir com" do Dolphin não lista apps
mkdir -p "$HOME/.config/menus"
[ -f /tmp/hyprland-dotfiles/.config/menus/applications.menu ] && \
  cp /tmp/hyprland-dotfiles/.config/menus/applications.menu "$HOME/.config/menus/"
mkdir -p "$HOME/.local/share/desktop-directories"
tee "$HOME/.local/share/desktop-directories/kde-applications.directory" > /dev/null <<'EOF'
[Desktop Entry]
Type=Directory
Icon=applications-other
Name=Applications
EOF
kbuildsycoca6 >/dev/null 2>&1 || true
ok "Menus KDE configurados (fix do 'Abrir com' no Dolphin)"
quote

# ──────────────────────────────────────────────
# 6a. Corrigir caminhos absolutos para o usuário atual
# ──────────────────────────────────────────────
step "🔄 Adaptando configs para seu usuário..."
info "Substituindo caminhos absolutos para o usuário atual"
find "$HOME/.config" -type f \( -name "*.json" -o -name "*.conf" -o -name "*.ini" \) \
  -exec sed -i "s|/home/[^/]*/|$HOME/|g" {} + 2>/dev/null || true
ok "Caminhos ajustados para $USER"
quote

# ──────────────────────────────────────────────
# 6b. Detectar resolução/refreshrate máximos e ajustar escala
# ──────────────────────────────────────────────
step "🖥️ Detectando resolução máxima do monitor..."

HYPR_LUA="$HOME/.config/hypr/hyprland.lua"

python3 - "$HYPR_LUA" << 'PYEOF' || warn "Falha ao detectar monitor — mantendo config padrão"
import os, re, sys, glob

LUA = sys.argv[1]

def parse_edid(path):
    try:
        data = open(path, "rb").read()
    except OSError:
        return None
    if len(data) < 128 or data[:8] != b"\x00\xff\xff\xff\xff\xff\xff\x00":
        return None
    dtd = data[0x36:0x48]
    pclk = (dtd[0] | (dtd[1] << 8)) * 10000
    ha = ((dtd[4] & 0xF0) << 4) | dtd[2]
    hbl = ((dtd[4] & 0x0F) << 8) | dtd[3]
    va = ((dtd[7] & 0xF0) << 4) | dtd[5]
    vbl = ((dtd[7] & 0x0F) << 8) | dtd[6]
    ht, vt = ha + hbl, va + vbl
    if ht == 0 or vt == 0:
        return None
    return (ha, va, round(pclk / (ht * vt)))

connector = None
for p in sorted(glob.glob("/sys/class/drm/card*-*/status")):
    try:
        if open(p).read().strip() == "connected":
            base = p[:p.rfind("/status")]
            if os.path.exists(base + "/edid"):
                connector = base
                break
    except OSError:
        continue

if connector is None:
    sys.exit(1)

info = parse_edid(connector + "/edid")
if info is None:
    sys.exit(1)

w, h, rr = info
if w >= 3840 or h >= 2160:
    scale = "2"
elif w >= 2560 or h >= 1440:
    scale = "1.5"
else:
    scale = "1"

mode = f"{w}x{h}@{rr}Hz"

if not os.path.isfile(LUA):
    sys.exit(1)

src = open(LUA).read()

def set_monitor_fields(m):
    blk = m.group(0)
    blk = re.sub(r'(mode\s*=\s*)"[^"]*"', r'\g<1>"%s"' % mode, blk)
    blk = re.sub(r'(scale\s*=\s*)\d+(?:\.\d+)?', r'\g<1>%s' % scale, blk)
    return blk

new = re.sub(r'hl\.monitor\(\{(?:[^{}]|\{[^{}]*\})*\}\)', set_monitor_fields, src)
open(LUA, "w").write(new)
print(f"{mode} scale={scale}")
PYEOF

if grep -q 'scale    = 2' "$HYPR_LUA" 2>/dev/null; then
  ok "Escala 2x detectada (4K)"
elif grep -q 'scale    = 1.5' "$HYPR_LUA" 2>/dev/null; then
  ok "Escala 1.5x detectada (1440p)"
elif grep -q 'scale    = 1' "$HYPR_LUA" 2>/dev/null; then
  ok "Escala 1x detectada (1080p)"
fi
quote

# ──────────────────────────────────────────────
# 7. SDDM (tela de login)
# ──────────────────────────────────────────────
step "🚀 Configurando SDDM..."

sudo systemctl enable sddm.service 2>&1 || true
ok "SDDM habilitado no systemd"

# Sessão padrão — Hyprland
SDDM_CONFIG="/etc/sddm.conf"
if [ -f "$SDDM_CONFIG" ]; then
  if grep -q "^Session=" "$SDDM_CONFIG"; then
    sudo sed -i 's/^Session=.*/Session=hyprland/' "$SDDM_CONFIG"
  else
    echo -e "[Autologin]\nSession=hyprland" | sudo tee -a "$SDDM_CONFIG" > /dev/null
  fi
else
  echo -e "[Autologin]\nSession=hyprland" | sudo tee "$SDDM_CONFIG" > /dev/null
fi
ok "SDDM: sessão padrão hyprland"
quote

# ──────────────────────────────────────────────
# 8. Ativar serviços
# ──────────────────────────────────────────────
step "⚡ Ativando serviços do sistema..."

info "Bluetooth..."
sudo systemctl enable --now bluetooth 2>&1 || true
ok "Bluetooth ativado"

info "PipeWire (áudio)..."
systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>&1 || true
ok "PipeWire ativado"

info "SDDM (login)..."
sudo systemctl enable sddm 2>&1 || true
ok "SDDM pronto para iniciar"

quote

# ──────────────────────────────────────────────
# 9. Configurar tema escuro
# ──────────────────────────────────────────────
step "🌙 Aplicando tema escuro..."

mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"

# Aplica o tema Qogir/Papirus já presente nos dotfiles baixados
if [ -f "$HOME/.config/gtk-3.0/settings.ini" ]; then
  ok "gtk-3.0/settings.ini presente (do repo)"
else
  warn "gtk-3.0/settings.ini não encontrado — tema escuro será aplicado via nwg-look"
fi

command -v nwg-look &>/dev/null && nwg-look -a 2>&1 || true

# Sincronizar com gsettings (Firefox e apps GNOME leem daqui)
if command -v gsettings &>/dev/null; then
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
  gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark' 2>/dev/null || true
  ok "gsettings sincronizado (color-scheme, icon-theme)"
fi

# Variáveis Qt/KDE no ambiente do systemd user
mkdir -p "$HOME/.config/environment.d"
tee "$HOME/.config/environment.d/95-qt.conf" > /dev/null <<'EOF'
QT_QPA_PLATFORMTHEME=breeze
KDE_SESSION_VERSION=5
XDG_CURRENT_DESKTOP=KDE
EOF
systemctl --user import-environment QT_QPA_PLATFORMTHEME XDG_CURRENT_DESKTOP KDE_SESSION_VERSION 2>/dev/null || true
ok "Variáveis Qt/KDE no ambiente do systemd user (portal)"

# Fonte Ubuntu Bold no xsettingsd (apps GTK2)
mkdir -p "$HOME/.config/xsettingsd"
if [ -f "$HOME/.config/xsettingsd/xsettingsd.conf" ]; then
  if ! grep -q "Gtk/FontName" "$HOME/.config/xsettingsd/xsettingsd.conf"; then
    echo 'Gtk/FontName "Ubuntu Bold 12"' >> "$HOME/.config/xsettingsd/xsettingsd.conf"
  fi
else
  cat > "$HOME/.config/xsettingsd/xsettingsd.conf" << 'EOF'
Net/ThemeName "Adwaita"
Net/IconThemeName "Papirus-Dark"
Gtk/CursorThemeName "Adwaita"
Gtk/FontName "Ubuntu Bold 12"
Gtk/MonospaceFontName "Ubuntu Bold Mono 12"
Net/EnableEventSounds 1
EnableInputFeedbackSounds 0
Xft/Antialias 1
Xft/Hinting 1
Xft/HintStyle "hintslight"
Xft/RGBA "rgb"
EOF
fi

ok "Tema escuro aplicado — suave para os olhos"
quote

# ──────────────────────────────────────────────
# 10. Apps padrão
# ──────────────────────────────────────────────
step "🐬 Definindo apps padrão..."
info "Associando pastas ao Dolphin..."
xdg-mime default org.kde.dolphin.desktop inode/directory
xdg-mime default org.kde.dolphin.desktop x-scheme-handler/trash

# kate — texto
xdg-mime default org.kde.kate.desktop text/plain
xdg-mime default org.kde.kate.desktop application/xml
xdg-mime default org.kde.kate.desktop application/x-shellscript

ok "Apps padrão: Dolphin, kate"
quote

# ──────────────────────────────────────────────
# 10b. Firefox dark mode
# ──────────────────────────────────────────────
step "🔥 Configurando dark mode do Firefox..."

FF_LIB="/usr/lib/firefox"
if [ -d "$FF_LIB" ]; then
  sudo mkdir -p "$FF_LIB/defaults/pref"
  sudo tee "$FF_LIB/defaults/pref/autoconfig.js" > /dev/null << 'FFPREFEOF'
pref("general.config.filename", "autoconfig.cfg");
pref("general.config.obscure_value", 0);
pref("general.config.sandbox_enabled", false);
FFPREFEOF

  sudo tee "$FF_LIB/autoconfig.cfg" > /dev/null << 'FFCFGEOF'
// Segue o tema GTK (0=light, 1=dark, 2=auto/GTK)
defaultPref("ui.systemUsesDarkTheme", 2);
FFCFGEOF
  ok "Firefox: segue tema GTK automaticamente"
fi

for prof_dir in "$HOME"/.mozilla/firefox/*.default-release; do
  [ -d "$prof_dir" ] || continue
  cat > "$prof_dir/user.js" << 'FFUSEREOF'
user_pref("ui.systemUsesDarkTheme", 2);
FFUSEREOF
  ok "Firefox dark mode: $prof_dir"
done 2>/dev/null || true
quote

# ──────────────────────────────────────────────
# 11. Otimização de I/O e memória para desktop
# ──────────────────────────────────────────────
step "⚡ Otimizando I/O e memória para desktop..."

for disk in /sys/block/nvme*/queue/scheduler /sys/block/sd*/queue/scheduler; do
  [ -f "$disk" ] || continue
  disk_name=$(echo "$disk" | cut -d'/' -f4)
  if echo "$disk_name" | grep -q "^nvme"; then
    echo "none" | sudo tee "$disk" > /dev/null
    ok "$disk_name → none (NVMe)"
  elif echo "$disk_name" | grep -q "^sd"; then
    if [ -f "/sys/block/$disk_name/queue/rotational" ]; then
      rotational=$(cat "/sys/block/$disk_name/queue/rotational")
      if [ "$rotational" = "0" ]; then
        echo "mq-deadline" | sudo tee "$disk" > /dev/null
        ok "$disk_name → mq-deadline (SSD SATA)"
      else
        echo "bfq" | sudo tee "$disk" > /dev/null
        ok "$disk_name → bfq (HDD)"
      fi
    fi
  fi
done

sudo sysctl -w vm.dirty_ratio=5 > /dev/null
sudo sysctl -w vm.dirty_background_ratio=2 > /dev/null
sudo sysctl -w vm.dirty_writeback_centisecs=300 > /dev/null
sudo sysctl -w vm.dirty_expire_centisecs=1500 > /dev/null
sudo sysctl -w vm.page-cluster=3 > /dev/null
sudo sysctl -w vm.vfs_cache_pressure=50 > /dev/null

sudo tee /etc/sysctl.d/99-desktop-io.conf > /dev/null <<'EOF'
vm.dirty_ratio = 5
vm.dirty_background_ratio = 2
vm.dirty_writeback_centisecs = 300
vm.dirty_expire_centisecs = 1500
vm.dirty_ratio_bytes = 134217728
vm.page-cluster = 3
vm.vfs_cache_pressure = 50
EOF

sudo tee /etc/udev/rules.d/60-ioscheduler.rules > /dev/null <<'EOF'
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
EOF

ok "I/O otimizado — scheduler + dirty pages + cache"
quote

# ──────────────────────────────────────────────
# 12. Pacman parallel downloads + TRIM
# ──────────────────────────────────────────────
step "📦 Configurando pacman + TRIM..."

if grep -q "^#ParallelDownloads = 5" /etc/pacman.conf; then
  sudo sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 16/' /etc/pacman.conf
  ok "pacman: ParallelDownloads = 16"
elif grep -q "^ParallelDownloads" /etc/pacman.conf; then
  sudo sed -i 's/^ParallelDownloads = .*/ParallelDownloads = 16/' /etc/pacman.conf
  ok "pacman: ParallelDownloads atualizado para 16"
else
  info "pacman: ParallelDownloads já configurado"
fi

# Habilitar multilib (necessário para lib32-mangohud, steam, wine 32-bit)
if grep -q "^#\[multilib\]" /etc/pacman.conf; then
  sudo sed -i '/^#\[multilib\]/,+1 s/^#//' /etc/pacman.conf
  sudo pacman -Sy 2>/dev/null || true
  ok "pacman: multilib habilitado"
else
  info "pacman: multilib já habilitado ou não necessário"
fi

if systemctl is-enabled fstrim.timer &>/dev/null; then
  ok "fstrim.timer já habilitado"
elif lsblk -d -o ROTA 2>/dev/null | grep -q "^0$"; then
  sudo systemctl enable --now fstrim.timer 2>/dev/null && \
    ok "fstrim.timer habilitado (TRIM semanal)" || warn "Falha ao habilitar fstrim.timer"
else
  info "Nenhum SSD detectado — TRIM não habilitado"
fi

# ──────────────────────────────────────────────
# 12b. Swap — memória virtual
# ──────────────────────────────────────────────
step "🔄 Criando swap de 4GB..."

if swapon --show | grep -q "/swapfile"; then
  info "Swap já existe, ignorando"
else
  sudo dd if=/dev/zero of=/swapfile bs=1M count=4096 status=progress
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile

  if ! grep -q "^/swapfile" /etc/fstab; then
    echo "/swapfile none swap defaults 0 0" | sudo tee -a /etc/fstab
  fi
  ok "Swap de 4GB criado e ativado"
fi
quote

# ──────────────────────────────────────────────
# 13. Wine + filesystem
# ──────────────────────────────────────────────
step "🍷 Instalando wine e suporte a filesystems..."

sudo pacman -S --needed --noconfirm \
  wine winetricks wine-mono wine-gecko \
  ntfs-3g exfat-utils dosfstools btrfs-progs xfsprogs jfsutils f2fs-tools nilfs-utils udftools e2fsprogs
ok "Wine e filesystems instalados"
quote

# ──────────────────────────────────────────────
# 13b. MangoHud (overlay FPS)
# ──────────────────────────────────────────────
step "🎮 Configurando MangoHud..."
info "Gera ~/.config/MangoHud/MangoHud.conf com CPU/GPU detectados automaticamente"

MANGOHUD_SCRIPT="$HOME/.config/scripts/mangohud-config.sh"
if [ -f "$MANGOHUD_SCRIPT" ]; then
  bash "$MANGOHUD_SCRIPT" || warn "Falha ao gerar config do MangoHud"
else
  warn "mangohud-config.sh não encontrado em ~/.config/scripts"
fi

# Perguntar se quer habilitar globalmente (padrão: Sim — só apertar Enter)
ENV_FILE="$HOME/.config/environment.d/95-mangohud.conf"
echo ""
echo -n "  Habilitar MangoHud globalmente (MANGOHUD=1 em todos os apps)? [S/n]: "
read -r ENABLE_MANGOHUD
case "${ENABLE_MANGOHUD:-S}" in
  s|S|y|Y|"")
    if grep -q "^MANGOHUD=1" "$ENV_FILE" 2>/dev/null; then
      ok "MANGOHUD=1 já está no environment do Hyprland"
    else
      mkdir -p "$HOME/.config/environment.d"
      echo "MANGOHUD=1" >> "$ENV_FILE"
      ok "MANGOHUD=1 adicionado ao environment do Hyprland (reinicie a sessão para valer)"
    fi
    ;;
  *)
    warn "MangoHud não habilitado globalmente — use Shift_R+F12 para alternar por jogo"
    ;;
esac
quote

# ──────────────────────────────────────────────
# 14. xdg-user-dirs
# ──────────────────────────────────────────────
step "📁 Configurando diretórios do usuário..."
info "Criando Diretórios como Downloads, Documentos, Imagens..."
xdg-user-dirs-update 2>&1 || true
ok "Diretórios criados"

# ──────────────────────────────────────────────
# 15. Final — escolha do usuário
# ──────────────────────────────────────────────
clear 2>/dev/null || true
echo -e "${GREEN}"
echo '  ██╗      █████╗ ██████╗ ██╗    ██╗ ██████╗'
echo '  ██║     ██╔══██╗██╔══██╗██║    ██║██╔════╝'
echo '  ██║     ███████║██████╔╝██║ █╗ ██║██║     '
echo '  ██║     ██╔══██║██╔══██╗██║███╗██║██║     '
echo '  ███████╗██║  ██║██████╔╝╚███╔███╔╝╚██████╗'
echo '  ╚══════╝╚═╝  ╚═╝╚═════╝  ╚══╝╚══╝  ╚═════╝'
echo -e "${NC}"
echo ""
echo -e "  ${GREEN}✔${NC} Sistema configurado com sucesso! By eusouobn"
echo ""
echo -e "  ${BOLD}O que deseja fazer agora?${NC}"
echo ""
echo -e "  ${CYAN}[1]${NC} Iniciar SDDM agora (tela de login)"
echo -e "  ${CYAN}[2]${NC} Reiniciar o sistema"
echo -e "  ${CYAN}[3]${NC} Sair (voltar ao terminal)"
echo ""
echo -n "  Escolha [1/2/3]: "
read -r choice

# Limpar repo temporário
rm -rf /tmp/hyprland-dotfiles

case "$choice" in
  1)
    echo ""
    info "Iniciando SDDM..."
    sudo systemctl start sddm
    ;;
  2)
    echo ""
    info "Reiniciando em 5 segundos... Pressione Ctrl+C para cancelar"
    sleep 5
    sudo reboot
    ;;
  *)
    echo ""
    info "Voltando ao terminal. Para iniciar o SDDM manualmente:"
    echo ""
    echo "    sudo systemctl start sddm"
    echo ""
    ;;
esac
