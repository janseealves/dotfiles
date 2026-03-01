# dotfiles

Configurações pessoais do meu setup **Hyprland + [end4/illogical-impulse](https://github.com/end-4/dots-hyprland)** no CachyOS / Arch Linux.

## Componentes

| Componente | Descrição |
|---|---|
| **WM** | Hyprland |
| **Shell** | Fish |
| **Bar / Widgets** | Quickshell (illogical-impulse) |
| **Terminal** | Kitty / Foot |
| **Launcher** | Fuzzel |
| **Logout** | wlogout |
| **Temas** | Matugen (Material You) |
| **Login** | SDDM + ii-sddm-theme |
| **Prompt** | Starship |
| **Visualizador de áudio** | Cava |

## Instalação em máquina nova

> Requer **Arch Linux** ou derivado (CachyOS, EndeavourOS, etc.)

### 1. Clonar o repositório

```bash
git clone --recurse-submodules https://github.com/SEU_USER/dotfiles.git ~/dotfiles
```

> `--recurse-submodules` é necessário para o `ii-sddm-theme`.

### 2. Rodar o instalador

```bash
cd ~/dotfiles
bash install.sh
```

O script faz automaticamente:
- Instala `paru` (AUR helper) se não tiver
- Instala todos os pacotes do illogical-impulse e extras
- Faz backup de configs existentes em `~/.config-backup-TIMESTAMP/`
- Cria symlinks via GNU Stow
- Instala o SDDM theme

### 3. Pós-instalação (obrigatório)

**Monitores** — crie `~/.config/hypr/monitors.conf` com sua resolução:
```
monitor=DP-1,1920x1080@144,0x0,1
```
Ou use `nwg-displays` para configurar graficamente.

**Wallpaper** — edite `~/.config/illogical-impulse/config.json` e atualize o campo `wallpaperPath`:
```json
"wallpaperPath": "/home/SEU_USER/Pictures/Wallpapers/sua_imagem.jpg"
```

**Workspaces** — se necessário, edite `~/.config/hypr/workspaces.conf`.

Depois, faça login no Hyprland via SDDM.

---

## Gerenciamento diário

Os arquivos em `~/.config/` são **symlinks** para este repositório. Qualquer edição é automaticamente rastreada.

```bash
# Ver o que mudou
git -C ~/dotfiles status

# Salvar mudanças
git -C ~/dotfiles add -A
git -C ~/dotfiles commit -m "descrição da mudança"
git -C ~/dotfiles push
```

## Estrutura

```
dotfiles/
├── .config/
│   ├── hypr/              # Hyprland (base + custom/)
│   ├── quickshell/        # Bar e widgets (illogical-impulse)
│   ├── illogical-impulse/ # Configurações do painel (config.json)
│   ├── fish/              # Shell
│   ├── kitty/             # Terminal principal
│   ├── foot/              # Terminal secundário
│   ├── fuzzel/            # Launcher
│   ├── wlogout/           # Menu de logout
│   ├── matugen/           # Geração de temas Material You
│   ├── fastfetch/         # Fetch do sistema
│   ├── cava/              # Visualizador de áudio
│   └── starship.toml      # Prompt do terminal
├── ii-sddm-theme/         # Tema do SDDM (submodule)
├── install.sh
└── README.md
```

## Arquivos ignorados pelo git

Estes arquivos são **específicos por máquina** e não são versionados:

- `~/.config/hypr/monitors.conf` — configuração de monitores
- `~/.config/hypr/workspaces.conf` — configuração de workspaces
- `~/.config/fish/fish_variables` — variáveis universais do Fish
