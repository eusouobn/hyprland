# Hyprland dotfiles

Configuração do meu Hyprland (Arch Linux): visual, keybinds, waybar, GTK e scripts.

## Requisitos

- Hyprland 0.56+
- waybar, kitty, grim, slurp, wl-clipboard, swww, nm-applet, blueman-applet
- rofi / nwg-drawer (launcher)
- nwg-look, qt5ct, qt6ct (tema)

## Instalação

```bash
# copiar as configs para sua home
cp -r .config/* ~/.config/

# shell
cp .bashrc .bash_profile ~/

# dependências (Arch)
sudo pacman -S hyprland waybar kitty grim slurp wl-clipboard swww \
  nm-connection-editor blueman rofi nwg-drawer nwg-look qt5ct qt6ct
```

## Estrutura

- `.config/hypr/` — hyprland.conf, script de toggle de monitor
- `.config/waybar/` — barra (config.jsonc + style.css)
- `.config/gtk-3.0/` e `.config/gtk-4.0/` — tema GTK (Qogir)
- `.config/scripts/` — scripts utilitários (screenshot, monitor, pacotes)

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
