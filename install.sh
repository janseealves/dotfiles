#!/usr/bin/env bash
# =============================================================================
# Dotfiles Install Script — janse
# Hyprland + end4/illogical-impulse setup
# =============================================================================
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${BLUE}[*]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[✗]${NC} $1"; exit 1; }

echo -e "${BOLD}"
echo "╔══════════════════════════════════════╗"
echo "║       janse dotfiles installer       ║"
echo "║   Hyprland + illogical-impulse       ║"
echo "╚══════════════════════════════════════╝"
echo -e "${NC}"

# =============================================================================
# 1. Verificar sistema
# =============================================================================
if [[ ! -f /etc/arch-release ]]; then
    error "Este script é para Arch Linux / CachyOS."
fi

# =============================================================================
# 2. AUR Helper (paru)
# =============================================================================
if ! command -v paru &>/dev/null && ! command -v yay &>/dev/null; then
    info "Instalando paru (AUR helper)..."
    sudo pacman -S --needed base-devel git
    git clone https://aur.archlinux.org/paru-bin.git /tmp/paru-bin
    cd /tmp/paru-bin && makepkg -si --noconfirm
    cd "$DOTFILES_DIR"
    success "paru instalado"
else
    success "AUR helper já instalado"
fi

AUR_HELPER=$(command -v paru || command -v yay)

# =============================================================================
# 3. Instalar pacotes
# =============================================================================
info "Instalando pacotes illogical-impulse..."
$AUR_HELPER -S --needed \
    illogical-impulse-basic \
    illogical-impulse-gtk \
    illogical-impulse-fonts-themes \
    illogical-impulse-python \
    illogical-impulse-toolkit \
    illogical-impulse-widgets-lite \
    illogical-impulse-microtex-git \
    quickshell

info "Instalando pacotes extras..."
$AUR_HELPER -S --needed --noconfirm \
    stow \
    fastfetch \
    bibata-cursor-theme \
    ttf-meslo-nerd \
    uwsm \
    wofi

success "Pacotes instalados"

# =============================================================================
# 4. SDDM theme (ii-sddm-theme)
# =============================================================================
if [[ -d "$DOTFILES_DIR/ii-sddm-theme" ]]; then
    info "Instalando ii-sddm-theme..."
    sudo mkdir -p /usr/share/sddm/themes/
    sudo cp -r "$DOTFILES_DIR/ii-sddm-theme" /usr/share/sddm/themes/ii-sddm-theme

    if [[ ! -f /etc/sddm.conf.d/theme.conf ]]; then
        sudo mkdir -p /etc/sddm.conf.d/
        echo -e "[Theme]\nCurrent=ii-sddm-theme" | sudo tee /etc/sddm.conf.d/theme.conf >/dev/null
    fi
    success "SDDM theme instalado"
fi

# =============================================================================
# 5. Criar monitores.conf (placeholder machine-specific)
# =============================================================================
MONITORS_CONF="$CONFIG_DIR/hypr/monitors.conf"
WORKSPACES_CONF="$CONFIG_DIR/hypr/workspaces.conf"

# =============================================================================
# 6. Fazer backup de configs existentes
# =============================================================================
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d_%H%M%S)"
CONFIGS_TO_LINK=(
    # hypr — stow folda no dir existente, lista arquivos individuais
    ".config/hypr/hyprland.conf"
    ".config/hypr/hyprlock.conf"
    ".config/hypr/hypridle.conf"
    ".config/hypr/custom"
    ".config/hypr/hyprlock"
    # outros configs completos
    ".config/fish"
    ".config/kitty"
    ".config/foot"
    ".config/fuzzel"
    ".config/wlogout"
    ".config/matugen"
    ".config/fastfetch"
    ".config/cava"
    ".config/quickshell"
    ".config/illogical-impulse"
    ".config/starship.toml"
    ".gitconfig"
)

NEED_BACKUP=false
for item in "${CONFIGS_TO_LINK[@]}"; do
    target="$HOME/$item"
    if [[ -e "$target" && ! -L "$target" ]]; then
        NEED_BACKUP=true
        break
    fi
done

if $NEED_BACKUP; then
    info "Fazendo backup de configs existentes em $BACKUP_DIR ..."
    mkdir -p "$BACKUP_DIR"
    for item in "${CONFIGS_TO_LINK[@]}"; do
        target="$HOME/$item"
        if [[ -e "$target" && ! -L "$target" ]]; then
            parent_dir="$BACKUP_DIR/$(dirname "$item")"
            mkdir -p "$parent_dir"
            mv "$target" "$parent_dir/"
        fi
    done
    success "Backup feito em $BACKUP_DIR"
fi

# =============================================================================
# 7. Criar symlinks com stow
# =============================================================================
info "Criando symlinks com stow..."
cd "$DOTFILES_DIR"
stow --target="$HOME" --restow .
success "Symlinks criados"

# =============================================================================
# 8. Criar arquivos machine-specific (se não existirem)
# =============================================================================
if [[ ! -f "$MONITORS_CONF" ]]; then
    warn "Crie $MONITORS_CONF com sua configuração de monitores."
    echo "# Adicione seus monitores aqui. Exemplo:" > "$MONITORS_CONF"
    echo "# monitor=DP-1,1920x1080@144,0x0,1" >> "$MONITORS_CONF"
fi

if [[ ! -f "$WORKSPACES_CONF" ]]; then
    warn "Crie $WORKSPACES_CONF com sua configuração de workspaces."
    echo "# Adicione seus workspaces aqui." > "$WORKSPACES_CONF"
fi

# =============================================================================
# 9. Ajustar wallpaper path em illogical-impulse/config.json
# =============================================================================
CONFIG_JSON="$CONFIG_DIR/illogical-impulse/config.json"
if [[ -f "$CONFIG_JSON" ]]; then
    if grep -q "/home/janse/" "$CONFIG_JSON"; then
        warn "config.json tem wallpaperPath hardcoded para /home/janse/"
        warn "Ajuste: $CONFIG_JSON"
    fi
fi

HYPRLOCK_COLORS="$CONFIG_DIR/hypr/hyprlock/colors.conf"
if [[ -f "$HYPRLOCK_COLORS" ]]; then
    if grep -q "/home/janse/" "$HYPRLOCK_COLORS"; then
        warn "hyprlock/colors.conf tem wallpaper path hardcoded para /home/janse/"
        warn "Ajuste ou rode matugen para regenerar: $HYPRLOCK_COLORS"
    fi
fi

# =============================================================================
# 10. Limine (bootloader) — SOMENTE se quiser replicar config
# =============================================================================
LIMINE_SRC="$DOTFILES_DIR/etc/default/limine"
if [[ -f "$LIMINE_SRC" ]]; then
    warn "Config do Limine disponível em: $LIMINE_SRC"
    warn "ATENÇÃO: contém UUID do disco original. NÃO copie sem ajustar o UUID!"
    warn "Para aplicar manualmente: sudo cp $LIMINE_SRC /etc/default/limine"
fi

# =============================================================================
# Done!
# =============================================================================
echo ""
echo -e "${GREEN}${BOLD}Instalação concluída!${NC}"
echo ""
echo -e "Próximos passos:"
echo -e "  1. Configure seus monitores em: ${BOLD}~/.config/hypr/monitors.conf${NC}"
echo -e "  2. Configure workspaces em:     ${BOLD}~/.config/hypr/workspaces.conf${NC}"
echo -e "  3. Ajuste wallpaper paths em:   ${BOLD}~/.config/illogical-impulse/config.json${NC}"
echo -e "                                  ${BOLD}~/.config/hypr/hyprlock/colors.conf${NC}"
echo -e "  4. Revise e aplique o Limine:   ${BOLD}$DOTFILES_DIR/etc/default/limine${NC}"
echo -e "  5. Reinicie o sistema ou faça login no Hyprland via SDDM"
echo ""
