# Hyprland dotfiles

Configuração do meu Hyprland (Arch Linux): visual, keybinds, waybar, GTK e scripts. Inclui instalador completo do Arch Linux com a opção Hyprland.

## Instalação completa (do zero)

### 1. Tenha o Arch Linux instalado

Se ainda não instalou, use o `install.sh` interativo a partir do ISO:

```bash
git clone https://github.com/eusouobn/hyprland
cd hyprland
sudo bash scripts/install.sh
```

Durante a instalação, na etapa **Interface Gráfica**, escolha a opção **12) Hyprland (Wayland)**.

Esse instalador cria o sistema básico (partições, rede, áudio, driver de vídeo, GRUB) e copia o `hyprland.sh` para `~/scripts/`. Não instala o Hyprland — só o necessário para o sistema iniciar.

### 2. Rode o script de instalação completa

Após reiniciar, faça login com seu usuário e rode:

```bash
bash ~/scripts/hyprland.sh
```

Ou, se preferir clonar o repo:

```bash
git clone https://github.com/eusouobn/hyprland
cd hyprland
bash scripts/hyprland.sh
```

**O que ele faz:**

- Instala yay (AUR helper) e otimiza MAKEFLAGS
- Instala todos os pacotes (Hyprland, Waybar, Dolphin, Firefox, áudio, Bluetooth, tema Papirus, fontes, wine, etc.)
- Configura SDDM (login) com sessão Hyprland
- Ativa Bluetooth, PipeWire e serviços necessários
- Baixa os dotfiles deste repo e aplica as configs
- Aplica tema escuro e apps padrão
- Otimiza I/O, swap e pacman
- No final pergunta se quer iniciar o SDDM ou reiniciar

### 3. Configurar o GitHub (para o OpenCode)

```bash
bash ~/scripts/github.sh
```

Configura o GitHub CLI (`gh`), identidade git e autenticação via HTTPS (fluxo do dispositivo).

## Instalação manual (só as configs)

```bash
# copiar as configs para sua home
cp -r .config/* ~/.config/

# shell
cp .bashrc .bash_profile ~/

# dependências (Arch)
sudo pacman -S hyprland waybar kitty grim slurp wl-clipboard awww \
  nm-connection-editor blueman rofi nwg-drawer nwg-look qt5ct qt6ct
```

## Keybinds principais

| Tecla | Ação |
| --- | --- |
| `SUPER + T` | Terminal (kitty) |
| `SUPER + Q` | Fechar janela |
| `SUPER + E` | File manager (dolphin) |
| `SUPER + W` | Launcher (nwg-drawer) |
| `SUPER + X` | Firefox |
| `SUPER + R` | Rofi |
| `SUPER + P` | Pseudotiling |
| `SUPER + J` | Toggle split |
| `SUPER + V` | Toggle floating |
| `SUPER + F` | Fullscreen |
| `SUPER + SPACE` | Desligar |
| `SUPER + M` | Monitor game |
| `SUPER + CTRL + M` | Monitor capture |
| `SUPER + ESC` | Reiniciar waybar |
| `SUPER + SHIFT + setas` | Redimensionar janela |
| `Print` | Screenshot (salvar + clipboard) |

> `SUPER` = tecla Super (a do Windows/Comando)

## Estrutura

```
hyprland/
├── scripts/
│   ├── install.sh        ← Instalador interativo Arch Linux (opção 12 = Hyprland)
│   ├── hyprland.sh       ← Script de instalação completa pós-reboot
│   └── github.sh         ← Autenticação GitHub para o OpenCode
├── .config/
│   ├── hypr/             ← hyprland.conf, scripts de monitor
│   ├── waybar/           ← Config da barra (config.jsonc + style.css)
│   ├── gtk-3.0/ gtk-4.0/ ← Tema GTK
│   ├── kitty/            ← Terminal
│   └── scripts/          ← Scripts utilitários (screenshot, monitor, pacotes)
└── README.md
```

## Dicas

- **Atualizar o sistema**: `sudo pacman -Syu`
- **Instalar programas do AUR**: `yay -S nome-do-pacote`
- **Mudar tema de ícones**: `nwg-look`
