# Setup PC

Playbook Ansible para automatizar a configuração do sistema após uma reinstalação.

> [English version](README.md)

## Sumário

- [Estrutura](#estrutura)
- [Perfis suportados](#perfis-suportados)
- [Como usar](#como-usar)
- [Pacotes instalados](#pacotes-instalados)
- [Ferramentas de dev (mise)](#ferramentas-de-dev-mise)
- [Niri — Keybinds](#niri--keybinds)
- [tmux](#tmux)
- [Comandos úteis](#comandos-úteis)

## Estrutura

```
setup-pc/
├── site.yml              # Playbook principal
├── setup.sh              # Bootstrap (instala Ansible + collections)
├── group_vars/
│   ├── all.yml           # Pacotes comuns a todos os perfis
│   ├── cachyos_niri.yml  # Pacotes específicos do CachyOS + Niri
│   ├── archlinux.yml
│   ├── ubuntu.yml
│   └── fedora.yml
└── roles/
    ├── common/           # Shell, pacotes base, fish config
    ├── packages/         # Instalação de extra_packages por distro
    ├── aur/              # paru + pacotes AUR (Arch/CachyOS)
    ├── niri/             # Keybinds do Niri
    ├── theme/            # Tema GTK dark
    ├── tmux/             # Config do tmux
    ├── mise/             # Runtime manager (linguagens)
    ├── dev_tools/        # Ferramentas de dev via mise
    ├── onepassword/
    ├── claude_code/
    ├── openclaude/
    ├── chromium/
    ├── slack/
    ├── antigravity/
    └── jetbrains_toolbox/
```

## Perfis suportados

| Perfil         | Distro             | Package manager |
|----------------|--------------------|-----------------|
| `cachyos-niri` | CachyOS            | pacman + paru   |
| `archlinux`    | Arch Linux         | pacman + paru   |
| `ubuntu`       | Ubuntu             | apt             |
| `fedora`       | Fedora             | dnf             |

## Como usar

### 1. Bootstrap

```sh
bash setup.sh
```

Instala o `ansible-core` e as collections necessárias (`community.general`, `kewlfft.aur`).

### 2. Rodar o playbook completo

```sh
ansible-playbook site.yml -i inventory/hosts
```

Vai pedir a senha sudo no início.

### 3. Rodar só as keybinds do Niri

```sh
ansible-playbook site.yml --tags keybinds
niri msg action load-config-file
```

---

## Pacotes instalados

### Todos os perfis (`group_vars/all.yml`)

- git, curl, wget, htop
- fish, nodejs, npm, ripgrep
- distrobox, github-cli
- tmux, wl-clipboard
- telegram-desktop, discord, steam

### CachyOS + Niri (`group_vars/cachyos_niri.yml`)

**Pacman:** niri, 1password, wtype + build deps para PHP via mise  
**AUR (paru):** slack-desktop

---

## Ferramentas de dev (mise)

Instaladas via `mise` em `~/.config/mise/config.toml`:

| Ferramenta   | Versão   |
|--------------|----------|
| terraform    | latest   |
| terragrunt   | latest   |
| kubectl      | latest   |
| helm         | latest   |
| rust         | latest   |
| go           | latest   |
| java         | 21 (LTS) |
| uv           | latest   |
| php          | latest   |

---

## Niri — Keybinds

> `Mod` = tecla Super (Windows)

### Aplicações

| Atalho | Ação |
|--------|------|
| `Mod+Return` | Terminal (Alacritty + tmux) |
| `Mod+Ctrl+Return` | App launcher (noctalia) |
| `Mod+B` | Chromium |
| `Mod+E` | Nautilus (file manager) |
| `Mod+Alt+L` | Bloquear tela |
| `Mod+Shift+Q` | Session menu |

### Copiar / Colar

| Atalho | Ação |
|--------|------|
| `Mod+C` | Copiar (universal) |
| `Mod+V` | Colar (universal) |

> Dentro do tmux: `Mod+C` entra em copy mode. Seleciona com mouse ou `v`, depois `Mod+C` / `y` / `Enter` pra copiar.

### Janelas — Foco

| Atalho | Ação |
|--------|------|
| `Mod+H/L` ou `Mod+←/→` | Foco coluna esquerda/direita |
| `Mod+K/J` ou `Mod+↑/↓` | Foco janela acima/abaixo |
| `Mod+Q` | Fechar janela |

### Janelas — Mover

| Atalho | Ação |
|--------|------|
| `Mod+Shift+←/→` | Mover coluna esquerda/direita |
| `Mod+Shift+↑/↓` | Mover janela acima/abaixo |
| `Mod+Ctrl+H/L` | Mover coluna esquerda/direita |
| `Mod+Ctrl+K/J` | Mover janela acima/abaixo |

### Monitores

| Atalho | Ação |
|--------|------|
| `Mod+Ctrl+←/→` | Foco monitor esquerda/direita |
| `Mod+Ctrl+↑/↓` | Foco monitor acima/abaixo |
| `Mod+Shift+Ctrl+←/→/↑/↓` | Mover coluna para outro monitor |

### Workspaces

| Atalho | Ação |
|--------|------|
| `Mod+[1-9]` | Ir para workspace N |
| `Mod+Shift+[1-9]` | Mover janela para workspace N |
| `Mod+Tab` | Workspace anterior |
| `Mod+Scroll` | Navegar workspaces |

### Layout

| Atalho | Ação |
|--------|------|
| `Mod+Shift+C` | Centralizar coluna |
| `Mod+M` | Maximizar coluna |
| `Mod+Ctrl+F` | Expandir coluna à largura disponível |
| `Mod+Ctrl+C` | Centralizar colunas visíveis |
| `Mod+Minus / Equal` | Reduzir / aumentar largura da coluna |
| `Mod+Shift+Minus / Equal` | Reduzir / aumentar altura da janela |

### Modos

| Atalho | Ação |
|--------|------|
| `Mod+F` | Fullscreen |
| `Mod+T` | Floating |
| `Mod+W` | Modo tabbed |
| `Mod+O` | Overview |

### Screenshots

| Atalho | Ação |
|--------|------|
| `Ctrl+Shift+1` | Screenshot (seleção) |
| `Ctrl+Shift+2` | Screenshot da tela |
| `Ctrl+Shift+3` | Screenshot da janela |

### Sistema

| Atalho | Ação |
|--------|------|
| `Mod+Shift+Escape` | Hotkey overlay |
| `Mod+Escape` | Desativar inibidor de atalhos |
| `Mod+Shift+P` | Desligar monitores |
| `Ctrl+Alt+Delete` | Sair do Niri |

---

## tmux

**Prefix:** `Ctrl+Space` (alternativo: `Ctrl+B`)

### Panes

| Atalho | Ação |
|--------|------|
| `Prefix+h` | Split horizontal |
| `Prefix+v` | Split vertical |
| `Prefix+x` | Fechar pane |
| `Ctrl+Alt+←/→/↑/↓` | Navegar entre panes |
| `Ctrl+Alt+Shift+←/→/↑/↓` | Redimensionar pane |

### Janelas

| Atalho | Ação |
|--------|------|
| `Prefix+c` | Nova janela |
| `Prefix+k` | Fechar janela |
| `Prefix+r` | Renomear janela |
| `Alt+[1-9]` | Ir para janela N |
| `Alt+←/→` | Janela anterior/próxima |
| `Alt+Shift+←/→` | Mover janela |

### Sessões

| Atalho | Ação |
|--------|------|
| `Prefix+C` | Nova sessão |
| `Prefix+K` | Fechar sessão |
| `Prefix+R` | Renomear sessão |
| `Alt+↑/↓` | Navegar sessões |

### Copy mode (vi)

| Atalho | Ação |
|--------|------|
| `Mod+C` / `Ctrl+Insert` | Entrar em copy mode |
| `v` | Iniciar seleção |
| `y` / `Enter` / `Mod+C` | Copiar para clipboard |
| Mouse drag | Selecionar e copiar automaticamente |

### Outros

| Atalho | Ação |
|--------|------|
| `Prefix+q` | Recarregar tmux.conf |

---

## Comandos úteis

### Recarregar config do Niri

```sh
niri msg action load-config-file
```

### Recarregar config do tmux

```sh
tmux source ~/.config/tmux/tmux.conf
```

### Rodar só as keybinds via Ansible

```sh
ansible-playbook site.yml --tags keybinds
```
