# Setup PC

Ansible playbook to automate system setup after a fresh install.

> [Versão em Português](README.pt.md)

## Structure

```
setup-pc/
├── site.yml              # Main playbook
├── setup.sh              # Bootstrap (installs Ansible + collections)
├── group_vars/
│   ├── all.yml           # Packages common to all profiles
│   ├── cachyos_niri.yml  # CachyOS + Niri specific packages
│   ├── archlinux.yml
│   ├── ubuntu.yml
│   └── fedora.yml
└── roles/
    ├── common/           # Shell, base packages, fish config
    ├── packages/         # extra_packages installation per distro
    ├── aur/              # paru + AUR packages (Arch/CachyOS)
    ├── niri/             # Niri keybinds
    ├── theme/            # GTK dark theme
    ├── tmux/             # tmux config
    ├── mise/             # Runtime manager (languages)
    ├── dev_tools/        # Dev tools via mise
    ├── onepassword/
    ├── claude_code/
    ├── openclaude/
    ├── chromium/
    ├── slack/
    ├── antigravity/
    └── jetbrains_toolbox/
```

## Supported profiles

| Profile        | Distro     | Package manager |
|----------------|------------|-----------------|
| `cachyos-niri` | CachyOS    | pacman + paru   |
| `archlinux`    | Arch Linux | pacman + paru   |
| `ubuntu`       | Ubuntu     | apt             |
| `fedora`       | Fedora     | dnf             |

## Usage

### 1. Bootstrap

```sh
bash setup.sh
```

Installs `ansible-core` and required collections (`community.general`, `kewlfft.aur`).

### 2. Run the full playbook

```sh
ansible-playbook site.yml -i inventory/hosts
```

You will be prompted for your sudo password at the start.

### 3. Apply only Niri keybinds

```sh
ansible-playbook site.yml --tags keybinds
niri msg action load-config-file
```

---

## Installed packages

### All profiles (`group_vars/all.yml`)

- git, curl, wget, htop
- fish, nodejs, npm, ripgrep
- distrobox, github-cli
- tmux, wl-clipboard
- telegram-desktop, discord, steam

### CachyOS + Niri (`group_vars/cachyos_niri.yml`)

**Pacman:** niri, 1password, wtype + PHP build deps via mise  
**AUR (paru):** slack-desktop

---

## Dev tools (mise)

Installed via `mise` at `~/.config/mise/config.toml`:

| Tool       | Version  |
|------------|----------|
| terraform  | latest   |
| terragrunt | latest   |
| kubectl    | latest   |
| helm       | latest   |
| rust       | latest   |
| go         | latest   |
| java       | 21 (LTS) |
| uv         | latest   |
| php        | latest   |

---

## Niri — Keybinds

> `Mod` = Super key (Windows key)

### Applications

| Shortcut | Action |
|----------|--------|
| `Mod+Return` | Terminal (Alacritty + tmux) |
| `Mod+Ctrl+Return` | App launcher (noctalia) |
| `Mod+B` | Chromium |
| `Mod+E` | Nautilus (file manager) |
| `Mod+Alt+L` | Lock screen |
| `Mod+Shift+Q` | Session menu |

### Copy / Paste

| Shortcut | Action |
|----------|--------|
| `Mod+C` | Copy (universal) |
| `Mod+V` | Paste (universal) |

> Inside tmux: `Mod+C` enters copy mode. Select with mouse or `v`, then `Mod+C` / `y` / `Enter` to copy.

### Windows — Focus

| Shortcut | Action |
|----------|--------|
| `Mod+H/L` or `Mod+←/→` | Focus column left/right |
| `Mod+K/J` or `Mod+↑/↓` | Focus window up/down |
| `Mod+Q` | Close window |

### Windows — Move

| Shortcut | Action |
|----------|--------|
| `Mod+Shift+←/→` | Move column left/right |
| `Mod+Shift+↑/↓` | Move window up/down |
| `Mod+Ctrl+H/L` | Move column left/right |
| `Mod+Ctrl+K/J` | Move window up/down |

### Monitors

| Shortcut | Action |
|----------|--------|
| `Mod+Ctrl+←/→` | Focus monitor left/right |
| `Mod+Ctrl+↑/↓` | Focus monitor up/down |
| `Mod+Shift+Ctrl+←/→/↑/↓` | Move column to another monitor |

### Workspaces

| Shortcut | Action |
|----------|--------|
| `Mod+[1-9]` | Go to workspace N |
| `Mod+Shift+[1-9]` | Move window to workspace N |
| `Mod+Tab` | Previous workspace |
| `Mod+Scroll` | Navigate workspaces |

### Layout

| Shortcut | Action |
|----------|--------|
| `Mod+Shift+C` | Center column |
| `Mod+M` | Maximize column |
| `Mod+Ctrl+F` | Expand column to available width |
| `Mod+Ctrl+C` | Center visible columns |
| `Mod+Minus / Equal` | Decrease / increase column width |
| `Mod+Shift+Minus / Equal` | Decrease / increase window height |

### Modes

| Shortcut | Action |
|----------|--------|
| `Mod+F` | Fullscreen |
| `Mod+T` | Floating |
| `Mod+W` | Tabbed mode |
| `Mod+O` | Overview |

### Screenshots

| Shortcut | Action |
|----------|--------|
| `Ctrl+Shift+1` | Screenshot (selection) |
| `Ctrl+Shift+2` | Screenshot screen |
| `Ctrl+Shift+3` | Screenshot window |

### System

| Shortcut | Action |
|----------|--------|
| `Mod+Shift+Escape` | Hotkey overlay |
| `Mod+Escape` | Toggle keyboard shortcuts inhibitor |
| `Mod+Shift+P` | Power off monitors |
| `Ctrl+Alt+Delete` | Quit Niri |

---

## tmux

**Prefix:** `Ctrl+Space` (alternative: `Ctrl+B`)

### Panes

| Shortcut | Action |
|----------|--------|
| `Prefix+h` | Split horizontal |
| `Prefix+v` | Split vertical |
| `Prefix+x` | Close pane |
| `Ctrl+Alt+←/→/↑/↓` | Navigate panes |
| `Ctrl+Alt+Shift+←/→/↑/↓` | Resize pane |

### Windows

| Shortcut | Action |
|----------|--------|
| `Prefix+c` | New window |
| `Prefix+k` | Close window |
| `Prefix+r` | Rename window |
| `Alt+[1-9]` | Go to window N |
| `Alt+←/→` | Previous/next window |
| `Alt+Shift+←/→` | Move window |

### Sessions

| Shortcut | Action |
|----------|--------|
| `Prefix+C` | New session |
| `Prefix+K` | Close session |
| `Prefix+R` | Rename session |
| `Alt+↑/↓` | Navigate sessions |

### Copy mode (vi)

| Shortcut | Action |
|----------|--------|
| `Mod+C` / `Ctrl+Insert` | Enter copy mode |
| `v` | Begin selection |
| `y` / `Enter` / `Mod+C` | Copy to clipboard |
| Mouse drag | Select and copy automatically |

### Other

| Shortcut | Action |
|----------|--------|
| `Prefix+q` | Reload tmux.conf |

---

## Useful commands

### Reload Niri config

```sh
niri msg action load-config-file
```

### Reload tmux config

```sh
tmux source ~/.config/tmux/tmux.conf
```

### Apply only keybinds via Ansible

```sh
ansible-playbook site.yml --tags keybinds
```
