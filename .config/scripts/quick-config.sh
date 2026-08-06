#!/bin/bash

# Configuração rápida do Hyprland
#   1) Monitor  : resolução / refresh rate com aplicação temporária e timeout
#   2) Visual   : mostra fontes em uso e troca a normal e a monoespaçada

REPO_DOTS="${REPO_DOTS:-/home/bn/hyprland/.config}"
TIMEOUT="${QUICK_CONFIG_TIMEOUT:-10}"

error() { printf 'Erro: %s\n' "$*" >&2; }
have()  { command -v "$1" >/dev/null 2>&1; }

# ---------- utilidades ----------

select_from() {
    local -a items=("$@") i
    [ "${#items[@]}" -eq 0 ] && return 1
    for i in "${!items[@]}"; do
        printf '  %d) %s\n' "$((i + 1))" "${items[$i]}" >&2
    done
    local n
    read -rp "Escolha (1-${#items[@]}): " n >&2
    if [[ "$n" =~ ^[0-9]+$ ]] && (( n >= 1 && n <= ${#items[@]} )); then
        printf '%s\n' "${items[$((n - 1))]}"
        return 0
    fi
    return 1
}

# aplica a função de edição (1º argumento) no arquivo do live e no do repo
patch_both() {
    local rel="$1"; shift
    local func="$1"; shift
    local live="$HOME/.config/$rel"
    [ -f "$live" ] && "$func" "$live" "$@"
    if [ -d "$REPO_DOTS" ] && [ -f "$REPO_DOTS/$rel" ] && [ "$REPO_DOTS/$rel" != "$live" ]; then
        "$func" "$REPO_DOTS/$rel" "$@"
    fi
}

# ---------- edição de arquivos ----------

set_ini() {    # FILE KEY VALUE
    local file="$1" key="$2" val="$3"
    if grep -q "^[[:space:]]*$key[[:space:]]*=" "$file"; then
        sed -i "s|^\([[:space:]]*$key[[:space:]]*=[[:space:]]*\).*|\1$val|" "$file"
    else
        printf '%s=%s\n' "$key" "$val" >> "$file"
    fi
}

set_xsettings() {    # FILE KEY VALUE  (Gtk/FontName "...")
    local file="$1" key="$2" val="$3"
    if grep -q "^$key " "$file"; then
        sed -i "s|^\($key[[:space:]]*\"\).*\(\"\)$|\1$val\2|" "$file"
    else
        printf '%s "%s"\n' "$key" "$val" >> "$file"
    fi
}

set_fc_alias() {    # FILE KIND VALUE  (alias sans-serif|monospace → family)
    local file="$1" kind="$2" val="$3" tmp
    tmp=$(mktemp) || return 1
    awk -v kind="$kind" -v val="$val" '
        /<alias>/        { in_alias = 1; fam = ""; target = 0 }
        in_alias && fam == "" && /<family>/ {
            if (match($0, /<family>[^<]*<\/family>/))
                target = (substr($0, RSTART + 8, RLENGTH - 17) == kind) ? 1 : 0
            fam = "set"
        }
        in_alias && target && /<prefer>/ {
            sub(/<family>[^<]*<\/family>/, "<family>" val "</family>")
            target = 0
        }
        /<\/alias>/      { in_alias = 0; fam = ""; target = 0 }
        { print }
    ' "$file" > "$tmp" && mv "$tmp" "$file"
}

set_waybar_font() {    # FILE VALUE
    local file="$1" val="$2"
    sed -i "s|^\([[:space:]]*font-family:[[:space:]]*\)\"[^\"]*\"|\1\"$val\"|" "$file"
}

set_lua_mode() {    # FILE MONITOR MODE
    local file="$1" mon="$2" mode="$3" tmp
    tmp=$(mktemp) || return 1
    awk -v mon="$mon" -v mode="$mode" '
        /hl\.monitor/ { block = 1 }
        block && /output/ && index($0, "\"" mon "\"") { hit = 1 }
        block && hit && /mode[[:space:]]*=/ {
            sub(/mode[[:space:]]*=[[:space:]]*"[^"]*"/, "mode = \"" mode "\"")
            hit = 0
        }
        { print }
    ' "$file" > "$tmp" && mv "$tmp" "$file"
}

# ---------- leitura ----------

get_ini() {    # FILE KEY
    [ -f "$1" ] && sed -n "s|^[[:space:]]*$2[[:space:]]*=[[:space:]]*||p" "$1" | head -1
}

get_xsettings() {    # FILE KEY
    [ -f "$1" ] && sed -n "s|^$2[[:space:]]*\"\(.*\)\"[[:space:]]*$|\1|p" "$1" | head -1
}

get_fc_alias() {    # FILE KIND
    [ -f "$1" ] || return 0
    awk -v kind="$2" '
        /<alias>/        { in_alias = 1; fam = ""; target = 0 }
        in_alias && fam == "" && /<family>/ {
            if (match($0, /<family>[^<]*<\/family>/))
                target = (substr($0, RSTART + 8, RLENGTH - 17) == kind) ? 1 : 0
            fam = "set"
        }
        in_alias && target && /<prefer>/ {
            if (match($0, /<family>[^<]*<\/family>/)) {
                print substr($0, RSTART + 8, RLENGTH - 17)
                exit
            }
        }
        /<\/alias>/      { in_alias = 0; fam = ""; target = 0 }
    ' "$1"
}

get_waybar_font() {
    [ -f "$1" ] || return 0
    sed -n 's|^[[:space:]]*font-family:[[:space:]]*"\([^"]*\)".*|\1|p' "$1" | head -1
}

# ---------- fontes ----------

fc_families() {
    fc-list : family | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

fc_styles() {    # FAMILY
    fc-list "$1" : style | sed -n 's/^:style=//p' | tr ',' '\n' \
        | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sort -u
}

pick_family() {    # KINDLABEL
    local kind="$1" q matches n sel
    local -a arr
    while :; do
        read -rp "  Buscar família de fonte ($kind) [Enter = todas]: " q
        matches=$(fc_families | grep -i "${q// /.*}" | sort -u)
        n=$(printf '%s\n' "$matches" | grep -c .)
        [ "$n" -eq 0 ] && { echo "  Nenhuma família encontrada."; continue; }
        if [ "$n" -gt 25 ]; then
            echo "  $n resultados — refine a busca."
            continue
        fi
        mapfile -t arr <<< "$matches"
        sel=$(select_from "${arr[@]}") || { echo "  Cancelado."; return 1; }
        [ -n "$sel" ] || { echo "  Cancelado."; return 1; }
        printf '%s\n' "$sel"
        return 0
    done
}

pick_style() {    # FAMILY → estilo (Regular se indefinido)
    local fam="$1" matches n sel
    local -a arr
    matches=$(fc_styles "$fam")
    n=$(printf '%s\n' "$matches" | grep -c .)
    [ "$n" -eq 0 ] && { printf 'Regular\n'; return 0; }
    [ "$n" -eq 1 ] && { printf '%s\n' "$matches"; return 0; }
    mapfile -t arr <<< "$matches"
    sel=$(select_from "${arr[@]}")
    printf '%s\n' "${sel:-Regular}"
}

font_size() {
    local s
    s=$(get_ini "$HOME/.config/gtk-3.0/settings.ini" gtk-font-name)
    s="${s##*, }"
    case "$s" in *[0-9]*) printf '%s\n' "$s" ;; *) printf '12\n' ;; esac
}

show_fonts() {
    local g3 g3m xd xdm fc_sans fc_mono wb
    g3=$(get_ini     "$HOME/.config/gtk-3.0/settings.ini" gtk-font-name)
    g3m=$(get_ini    "$HOME/.config/gtk-3.0/settings.ini" gtk-monospace-font-name)
    xd=$(get_xsettings "$HOME/.config/xsettingsd/xsettingsd.conf" Gtk/FontName)
    xdm=$(get_xsettings "$HOME/.config/xsettingsd/xsettingsd.conf" Gtk/MonospaceFontName)
    fc_sans=$(get_fc_alias "$HOME/.config/fontconfig/fonts.conf" sans-serif)
    fc_mono=$(get_fc_alias "$HOME/.config/fontconfig/fonts.conf" monospace)
    wb=$(get_waybar_font "$HOME/.config/waybar/style.css")
    printf '== Fontes em uso ==\n'
    printf '  Normal:       GTK %s\n'    "${g3:--}"
    printf '                XDG %s\n'    "${xd:--}"
    printf '                fc  %s\n'    "${fc_sans:--}"
    printf '  Monoespaçada: GTK %s\n'    "${g3m:--}"
    printf '                XDG %s\n'    "${xdm:--}"
    printf '                fc  %s\n'    "${fc_mono:--}"
    [ -n "$wb" ] && printf '  Waybar:       %s\n' "$wb"
}

apply_font() {    # normal|mono  "Family Style"
    local kind="$1" fam="$2" size="$3"
    local ini_key xd_key fc_kind
    if [ "$kind" = mono ]; then
        ini_key=gtk-monospace-font-name
        xd_key=Gtk/MonospaceFontName
        fc_kind=monospace
    else
        ini_key=gtk-font-name
        xd_key=Gtk/FontName
        fc_kind=sans-serif
    fi
    patch_both gtk-3.0/settings.ini        set_ini       "$ini_key" "$fam, $size"
    patch_both gtk-4.0/settings.ini        set_ini       "$ini_key" "$fam, $size"
    patch_both xsettingsd/xsettingsd.conf  set_xsettings "$xd_key" "$fam $size"
    patch_both fontconfig/fonts.conf       set_fc_alias  "$fc_kind" "$fam"
    [ "$kind" = normal ] && patch_both waybar/style.css set_waybar_font "$fam"
}

change_font() {    # normal|mono
    local kind="$1" size="$2" family style
    printf 'Fonte %s:\n' "$([ "$kind" = mono ] && echo monoespaçada || echo normal)"
    family=$(pick_family "$([ "$kind" = mono ] && echo monoespaçada || echo normal)") || return 1
    style=$(pick_style "$family")
    apply_font "$kind" "$family $style" "$size"
    printf 'Fonte %s alterada para: %s %s\n' "$kind" "$family" "$style"
}

font_menu() {
    local size
    size=$(font_size)
    while :; do
        echo
        show_fonts
        echo
        echo "  1) Alterar fonte normal"
        echo "  2) Alterar fonte monoespaçada"
        echo "  0) Voltar"
        read -rp "Opção: " opt
        case "$opt" in
            1) change_font normal "$size" ;;
            2) change_font mono    "$size" ;;
            0) return ;;
        esac
    done
}

# ---------- monitor ----------

norm_mode() {    # WxH@RR.xxxxx → WxH@RR.xx
    local mode="$1" w h rr
    w="${mode%%x*}"; h="${mode#*x}"; h="${h%%@*}"; rr="${mode#*@}"
    rr=$(LC_ALL=C printf '%.2f' "$rr" 2>/dev/null) || return
    printf '%sx%s@%s\n' "$w" "$h" "$rr"
}

monitor_apply() {    # MON MODE POS SCALE TRANSFORM VRR(0|1)
    local mon="$1" mode="$2" pos="$3" scale="$4" transform="$5" vrr="$6"
    local vrr_lua=true
    [ "$vrr" = 0 ] && vrr_lua=false
    hyprctl eval "hl.monitor({ output = \"$mon\", mode = \"$mode\", position = \"$pos\", scale = $scale, transform = $transform, vrr = $vrr_lua })"
}

apply_temp() {    # JSON MON MODE ORIG
    local json="$1" mon="$2" mode="$3" orig="$4"
    local x y pos scale transform vrr resp p
    local -i keep=0 i
    x=$(echo "$json" | jq -r --arg n "$mon" '.[] | select(.name == $n) | .x')
    y=$(echo "$json" | jq -r --arg n "$mon" '.[] | select(.name == $n) | .y')
    scale=$(echo "$json" | jq -r --arg n "$mon" '.[] | select(.name == $n) | .scale')
    transform=$(echo "$json" | jq -r --arg n "$mon" '.[] | select(.name == $n) | .transform')
    vrr=$(echo "$json" | jq -r --arg n "$mon" '.[] | select(.name == $n) | if .vrr then 1 else 0 end')
    pos="$x,$y"

    monitor_apply "$mon" "$mode" "$pos" "$scale" "$transform" "$vrr"
    echo "Aplicado temporariamente: $mon $mode (restaura em ${TIMEOUT}s se não confirmar)."
    for (( i = TIMEOUT; i > 0; i-- )); do
        printf '\r  Confirme para manter [S] — restaura em %2ds...' "$i"
        if read -t 1 -n 1 resp && [[ "$resp" =~ [sS] ]]; then
            keep=1
            break
        fi
    done
    printf '\r%*s\n' "$(tput cols 2>/dev/null || echo 40)" ""

    if (( keep )); then
        echo "Configuração mantida: $mon $mode"
        read -rp "Salvar permanentemente no hyprland.lua? [s/N] " p
        if [[ "$p" =~ [sS] ]]; then
            patch_both hypr/hyprland.lua set_lua_mode "$mon" "$mode"
            echo "hyprland.lua atualizado."
        fi
    else
        monitor_apply "$mon" "$orig" "$pos" "$scale" "$transform" "$vrr"
        echo "Restaurado para: $mon $orig"
    fi
}

configure_monitor() {    # JSON MON
    local json="$1" mon="$2"
    local orig modes res rr mode sel
    local -a reslist rrs
    orig=$(echo "$json" | jq -r --arg n "$mon" '.[] | select(.name == $n) | "\(.width)x\(.height)@\(.refreshRate)"')
    orig=$(norm_mode "$orig")
    modes=$(echo "$json" | jq -r --arg n "$mon" '.[] | select(.name == $n) | .availableModes[]')

    mapfile -t reslist < <(printf '%s\n' "$modes" | sed 's/@.*//' | sort -u -t x -k1,1nr -k2,2nr)
    echo
    echo "Monitor: $mon  (atual: $orig)"
    echo "== Resoluções =="
    sel=$(select_from "${reslist[@]}") || return 1
    res="$sel"

    mapfile -t rrs < <(printf '%s\n' "$modes" | grep "^$res@" | sed 's/^[^@]*@//;s/Hz$//' | sort -u -n)
    echo "== Refresh rates para $res =="
    sel=$(select_from "${rrs[@]}") || return 1
    rr="$sel"

    mode="${res}@${rr}"
    apply_temp "$json" "$mon" "$mode" "$orig"
}

monitor_menu() {
    have jq || { error "jq não está instalado."; return 1; }
    local json mi mon sel
    local -a mons descs
    json=$(hyprctl monitors -j 2>/dev/null) || { error "hyprctl falhou (Hyprland rodando?)."; return 1; }
    mapfile -t mons < <(echo "$json" | jq -r '.[].name')
    mapfile -t descs < <(echo "$json" | jq -r '.[] | .description // empty')
    echo "== Monitores =="
    for i in "${!mons[@]}"; do
        printf '  %d) %s%s\n' "$((i + 1))" "${mons[$i]}" "${descs[$i]:+ — ${descs[$i]}}"
    done
    read -rp "Escolha um monitor (0 = voltar): " mi
    [[ "$mi" =~ ^[0-9]+$ ]] || return 0
    (( mi >= 1 && mi <= ${#mons[@]} )) || return 0
    mon="${mons[$((mi - 1))]}"
    configure_monitor "$json" "$mon"
}

# ---------- menu principal ----------

main() {
    while :; do
        echo
        echo "== Configuração rápida do Hyprland =="
        echo "  1) Monitor (resolução / refresh rate)"
        echo "  2) Visual (fontes)"
        echo "  0) Sair"
        read -rp "Opção: " opt
        case "$opt" in
            1) monitor_menu ;;
            2) font_menu ;;
            0) echo "Tchau."; break ;;
            *) echo "Opção inválida." ;;
        esac
    done
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
