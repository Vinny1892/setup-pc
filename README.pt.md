# Setup PC

Playbook Ansible para automatizar a configuração do sistema após uma reinstalação.

> [English version](README.md)

## Sumário

- [Estrutura](#estrutura)
- [Perfis suportados](#perfis-suportados)
- [Como usar](#como-usar)
- [Pacotes instalados](#pacotes-instalados)
- [Ferramentas de dev (mise)](#ferramentas-de-dev-mise)
- [Ferramentas de shell](#ferramentas-de-shell)
- [Ferramentas de IA](#ferramentas-de-ia)
- [MCP servers](#mcp-servers)
- [Storage](#storage)
- [VPN](#vpn)
- [Gaming](#gaming)
- [Bootloader](#bootloader)
- [Secure Boot](#secure-boot)
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
    ├── dev_tools/        # Ferramentas de dev via mise (terraform, kubectl, go, rust…)
    ├── shell_tools/      # Substituições modernas de CLI + starship + atuin + git config
    ├── storage/          # ZRAM, snapshots snapper, CoW desabilitado para docker/ollama
    ├── docker/           # Docker, lazygit, lazydocker, kind, minikube
    ├── virtualization/   # virt-manager, gnome-boxes, stack QEMU/libvirt
    ├── virtual_display/  # Display virtual 4K via EDID + streaming com Sunshine
    ├── vpn/              # WireGuard + Cloudflare WARP
    ├── mcp/              # MCP servers (kubernetes, grafana, cloudflare)
    ├── skills/           # Skills do Claude Code (DiegoBulhoes/claude)
    ├── onepassword/
    ├── claude_code/
    ├── openclaude/
    ├── codex/            # OpenAI Codex CLI
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

Instala o `ansible-core` e as collections necessárias (`community.general`, `kewlfft.aur`). O script detecta o SO automaticamente e exibe os comandos prontos com o inventory correto.

### 2. Instalação em estágios (recomendado)

**Estágio 1 — Crítico** (storage + secure boot): faça isso primeiro em uma instalação nova.

```sh
ansible-playbook -i inventory/cachyos-niri.yml site.yml --tags storage,security
```

**Estágio 2 — Base** (ferramentas, desktop, devtools):

```sh
ansible-playbook -i inventory/cachyos-niri.yml site.yml --tags tools,cachyos,devtools,gaming
```

**Estágio 3 — IA** (Claude Code, MCPs, Codex):

```sh
ansible-playbook -i inventory/cachyos-niri.yml site.yml --tags ia
```

**Estágio 3b — ComfyUI** (opcional, demora bastante):

```sh
ansible-playbook -i inventory/cachyos-niri.yml site.yml --tags comfyui
```

> O inventory correto para o seu SO é exibido pelo `setup.sh` após o bootstrap.

### 3. Tags disponíveis

| Tag | O que roda |
|---|---|
| `tools` | common, packages, shell_tools, tmux, chromium, slack, onepassword, vpn |
| `devtools` | mise, dev_tools, docker, virtualization, jetbrains_toolbox |
| `ia` | claude_code, openclaude, codex, skills, mcp |
| `comfyui` | comfyui (isolado, não incluído em `ia`) |
| `gaming` | gaming, gamepad, virtual_display (só Arch/CachyOS) |
| `security` | secure_boot |
| `bootloader` | systemd-boot (só Arch/CachyOS) |
| `storage` | storage (ZRAM, snapper, CoW) |
| `niri` | niri, theme |
| `cachyos` | aur + roles cachyos/arch |
| `arch` | aur + roles base |
| `ubuntu` | roles base (apt) |
| `fedora` | roles base (dnf) |

### 4. Rodar só as keybinds do Niri

```sh
ansible-playbook -i inventory/cachyos-niri.yml site.yml --tags keybinds
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

**Pacman:** niri, 1password-cli, wtype + build deps para PHP via mise  
**AUR (paru):** 1password, slack-desktop, freelens-bin, gearlever

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

## Ferramentas de shell

Substituições modernas de CLI com aliases configurados no fish:

| Clássico | Substituto |
|----------|------------|
| `ls`     | eza        |
| `cat`    | bat        |
| `find`   | fd         |
| `grep`   | ripgrep    |
| `du`     | dust       |
| `df`     | duf        |
| `top`    | bottom     |
| `cd`     | zoxide     |
| `lg`     | lazygit    |
| `ldc`    | lazydocker |
| `k`      | kubectl    |

Inclui também **Starship** (prompt), **Atuin** (histórico encriptado) e **git-delta** (diffs side-by-side, merge style `zdiff3`).

---

## Ferramentas de IA

| Ferramenta  | Instalação     | Função                           |
|-------------|----------------|----------------------------------|
| claude      | install script | Claude Code CLI                  |
| openclaude  | npm            | Wrapper da Claude API            |
| codex       | npm            | OpenAI Codex CLI                 |
| comfyui     | tag própria    | Geração de imagens (opcional)    |

### ComfyUI

Roda dentro de um container distrobox (Arch Linux) com passthrough de GPU NVIDIA. A imagem é construída com `buildah` e já inclui `python-pytorch-opt-cuda` + `python-torchvision-cuda`. O diretório `~/comfyui/models/` do host é compartilhado automaticamente com o container.

```sh
comfyui   # inicia o servidor + abre o Chromium como PWA em http://127.0.0.1:8188
```

Fechar a janela do Chromium para o servidor automaticamente. Um `.desktop` entry é criado para lançar pelo app launcher do sistema.

Diretórios de modelos criados em `~/comfyui/models/`: `checkpoints`, `loras`, `vae`, `embeddings`, `controlnet`, `upscale_models`, `clip`, `diffusion_models`.

### Skills

Clonadas de [DiegoBulhoes/claude](https://github.com/DiegoBulhoes/claude) em `~/vinny/skills` e symlinkadas em `~/.claude/skills/` e `~/.claude/agents/`.

| Categoria  | Skills                                              |
|------------|-----------------------------------------------------|
| IaC        | terraform, terragrunt, ansible, iac-review          |
| Kubernetes | kubernetes, helm, kustomize, gitops                 |
| Dev        | golang, rust                                        |
| Workflow   | explore, audit, prd, tech-spec, technical-docs      |
| Agents     | terraform-expert, ansible-expert, spec-writer, cloud-troubleshooter |

---

## MCP servers

Configurados via `claude mcp add` (não edita o JSON diretamente — funciona mesmo em instalação nova do Claude Code):

| Server                | Transporte | Observações                              |
|-----------------------|------------|------------------------------------------|
| kubernetes-mcp-server | npx        | Read-only, usa `~/.kube/config`          |
| grafana               | uvx        | Definir `grafana_url` e `grafana_token`  |
| cloudflare            | HTTP       | `https://mcp.cloudflare.com/mcp`         |

Para definir credenciais do Grafana:
```sh
ansible-playbook -i inventory/cachyos-niri.yml site.yml --tags ia \
  -e grafana_url=https://myinstance.grafana.net -e grafana_token=<token>
```

---

## Storage

- **ZRAM**: 4GB de swap comprimido na RAM (zstd, priority 100) — usado antes de qualquer swap em disco
- **Snapper**: snapshots automáticos do Btrfs em `/` — 10 hourly, 7 daily, 1 weekly, 1 monthly, máx 50 total
- **CoW desabilitado**: `/var/lib/docker` e `/var/lib/ollama` usam `chattr +C` para evitar overhead do CoW do Btrfs

---

## VPN

- **WireGuard** (`wireguard-tools`) — config de tunnel não incluída, adicionar manualmente em `/etc/wireguard/`
- **Cloudflare WARP** (`cloudflare-warp-bin`) — `warp-svc` habilitado no boot; registrar uma vez após instalar:
  ```sh
  warp-cli register
  warp-cli connect
  ```

---

## Gaming

| Pacote | Função |
|---|---|
| `proton-cachyos` | Proton otimizado pelo CachyOS para Heroic e launchers fora do Steam |
| `proton-cachyos-slr` | Proton otimizado pelo CachyOS para Steam (build Steam Linux Runtime) |
| `umu-launcher` | Roda Proton fora do Steam (GOG, Epic, etc.) |
| `wine-cachyos-opt` | Wine otimizado pelo CachyOS |
| `winetricks` / `protontricks` | Configuração de prefixes Wine/Proton |
| `gamescope` | Micro compositor Wayland da Valve |
| `mangohud` + `lib32-mangohud` | Overlay de FPS/GPU/CPU (toggle: `Shift+F12`) |
| `goverlay` | GUI para configurar o MangoHud |
| `heroic-games-launcher-bin` | Launcher da Epic Games e GOG |
| `lutris` | Gerenciador de jogos multi-plataforma |
| `vulkan-tools` | Diagnóstico de Vulkan |
| `sunshine` | Host de streaming para Moonlight (repositório CachyOS) |

A config do MangoHud é instalada em `~/.config/MangoHud/MangoHud.conf`.  
A versão do Heroic é controlada pela variável `gaming_heroic_version` em `roles/gaming/defaults/main.yml`.

### Display virtual (só Arch/CachyOS)

O role `virtual_display` cria um display headless 4K via firmware EDID + parâmetro de kernel, usado como saída dedicada para streaming com Sunshine.

- Instala um binário EDID 4K em `/usr/lib/firmware/edid/4k.bin` e inclui no initramfs
- Adiciona os parâmetros `drm.edid_firmware` + `video=` a todas as entradas do systemd-boot
- Configura o Sunshine para capturar o conector virtual
- Desativa o output virtual no Niri por padrão (não aparece no desktop até ser ativado)
- Instala uma função `sunshine` no fish para alternar o display e iniciar o streaming:

```sh
sunshine on   # habilita o display virtual + inicia o Sunshine
sunshine off  # desabilita o display virtual + para o Sunshine
```

---

## Virtualização

Instalado pelo role `virtualization` (tag: `devtools`).

| Pacote | Função |
|---|---|
| `qemu-full` / `qemu-kvm` | Hypervisor QEMU |
| `libvirt` | API de gerenciamento de virtualização |
| `virt-manager` | GUI para gerenciar VMs via libvirt |
| `gnome-boxes` | Gerenciador de VMs simplificado do GNOME |
| `virt-viewer` | Cliente de display leve para VMs |
| `dnsmasq` | DHCP/DNS para redes virtuais |
| `edk2-ovmf` | Firmware UEFI para VMs |

O role também habilita o serviço `libvirtd` e adiciona o usuário aos grupos `libvirt` e `kvm` (necessário re-login após a primeira execução).

---

## Bootloader

O playbook assume que **systemd-boot** foi escolhido durante a instalação do CachyOS.

O role `bootloader`:

1. Valida via `bootctl` que systemd-boot é o bootloader atual (falha rápido se não for).
2. Ajusta defaults razoáveis em `/boot/loader/loader.conf` (timeout, console mode, editor desativado).
3. Roda `bootctl update` para o binário EFI na ESP bater com o pacote `systemd` instalado — o pacman hook `zz-sbctl` re-assina em seguida.

Se você instalou com outro bootloader, pule com `--skip-tags bootloader`.

## Secure Boot

Usa `sbctl` para enrollar chaves customizadas **junto** dos certificados Microsoft para que o Windows/BitLocker no segundo disco continue funcionando normalmente.

### Passo obrigatório na BIOS antes de rodar o playbook

O `sbctl enroll-keys` exige que o firmware esteja em **Setup Mode** para conseguir escrever no banco de chaves da UEFI. É um pré-requisito único:

1. Reinicia na BIOS/UEFI
2. Vai em **Security → Secure Boot**
3. Seleciona **Delete Secure Boot Keys** (ou "Reset to Setup Mode") — isso limpa as chaves temporariamente
4. **Não habilita o Secure Boot ainda** — só salva e volta pro Linux
5. Roda o playbook — ele enrolla suas chaves customizadas + certificados Microsoft automaticamente
6. Reinicia na BIOS de novo e habilita o Secure Boot em **User Mode**

> **Nota sobre BitLocker**: limpar as chaves no passo 3 não quebra o BitLocker. O flag `--microsoft` re-enrolla os mesmos certificados Microsoft, então o Windows continua bootando normalmente após o passo 6.

### O que o playbook faz

| Etapa | O que acontece | Idempotente? |
|---|---|---|
| Criação das chaves | Cria chaves em `/var/lib/sbctl/keys/` | Pulado se já existirem |
| Assert Setup Mode | Falha com mensagem acionável se o firmware não estiver em Setup Mode na primeira execução | Só na primeira vez |
| Enrollment | Enrolla chaves custom + Microsoft na firmware | Pulado se já enrolladas |
| Descobrir & registrar | Encontra `*.efi` e `vmlinuz-*` em `/boot` e registra cada um com `sbctl sign -s` pra popular o files.json | Sempre roda (idempotente) |
| Sign all | Re-assina todos os binários registrados | Sempre roda (seguro re-rodar) |
| Verify | Falha o play se **qualquer** binário não estiver assinado (strict) | Sempre roda |

Snapshots do snapper são criados antes e depois do setup — apenas na primeira execução.

O pacman hook do `sbctl` assina os binários automaticamente em cada atualização de kernel ou systemd.

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
| `Mod+Shift+Escape` / `Mod+Shift+H` | Hotkey overlay |
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
ansible-playbook -i inventory/cachyos-niri.yml site.yml --tags keybinds
```
