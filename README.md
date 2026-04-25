# Setup PC

Ansible playbook to automate system setup after a fresh install.

> [Versão em Português](README.pt.md)

## Table of Contents

- [Structure](#structure)
- [Supported profiles](#supported-profiles)
- [Usage](#usage)
- [Installed packages](#installed-packages)
- [Dev tools (mise)](#dev-tools-mise)
- [Shell tools](#shell-tools)
- [AI tools](#ai-tools)
- [MCP servers](#mcp-servers)
- [Storage](#storage)
- [VPN](#vpn)
- [Gaming](#gaming)
- [Bootloader](#bootloader)
- [Secure Boot](#secure-boot)
- [Niri — Keybinds](#niri--keybinds)
- [tmux](#tmux)
- [Useful commands](#useful-commands)

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
    ├── dev_tools/        # Dev tools via mise (terraform, kubectl, go, rust…)
    ├── shell_tools/      # Modern CLI replacements + starship + atuin + git config
    ├── storage/          # ZRAM, snapper snapshots, CoW disabled for docker/ollama
    ├── docker/           # Docker, lazygit, lazydocker, kind, minikube
    ├── virtualization/   # virt-manager, gnome-boxes, QEMU/libvirt stack
    ├── virtual_display/  # Virtual 4K display via EDID + Sunshine streaming
    ├── vpn/              # WireGuard + Cloudflare WARP
    ├── mcp/              # MCP servers (kubernetes, grafana, cloudflare)
    ├── skills/           # Claude Code skills from DiegoBulhoes/claude
    ├── onepassword/
    ├── claude_code/
    ├── openclaude/
    ├── codex/            # OpenAI Codex CLI
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

Installs `ansible-core` and required collections (`community.general`, `kewlfft.aur`). The script auto-detects your OS and prints ready-to-use commands with the correct inventory.

### 2. Staged installation (recommended)

**Stage 1 — Critical** (storage + secure boot): run this first on a fresh install.

```sh
ansible-playbook -i inventory/cachyos-niri.yml site.yml --tags storage,security
```

**Stage 2 — Base** (tools, desktop, devtools):

```sh
ansible-playbook -i inventory/cachyos-niri.yml site.yml --tags tools,cachyos,devtools,gaming
```

**Stage 3 — AI** (Claude Code, MCPs, Codex):

```sh
ansible-playbook -i inventory/cachyos-niri.yml site.yml --tags ia
```

**Stage 3b — ComfyUI** (optional, takes a while):

```sh
ansible-playbook -i inventory/cachyos-niri.yml site.yml --tags comfyui
```

> The correct inventory for your OS is shown by `setup.sh` after bootstrapping.

### 3. Available tags

| Tag | What runs |
|---|---|
| `tools` | common, packages, shell_tools, tmux, chromium, slack, onepassword, vpn |
| `devtools` | mise, dev_tools, docker, virtualization, jetbrains_toolbox |
| `ia` | claude_code, openclaude, codex, skills, mcp |
| `comfyui` | comfyui only (not included in `ia`) |
| `gaming` | gaming, gamepad, virtual_display (Arch/CachyOS only) |
| `security` | secure_boot |
| `bootloader` | systemd-boot (Arch/CachyOS only) |
| `storage` | storage (ZRAM, snapper, CoW) |
| `niri` | niri, theme |
| `cachyos` | aur + all cachyos/arch roles |
| `arch` | aur + base roles |
| `ubuntu` | base roles (apt) |
| `fedora` | base roles (dnf) |

### 4. Apply only Niri keybinds

```sh
ansible-playbook -i inventory/cachyos-niri.yml site.yml --tags keybinds
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

**Pacman:** niri, 1password-cli, wtype + PHP build deps via mise  
**AUR (paru):** 1password, slack-desktop, freelens-bin, gearlever

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

Also installed via AUR:

| Tool      | Purpose                  |
|-----------|--------------------------|
| freelens  | Kubernetes IDE (Lens fork) |

---

## Shell tools

Modern CLI replacements configured with aliases in fish:

| Classic | Replacement |
|---------|-------------|
| `ls`    | eza         |
| `cat`   | bat         |
| `find`  | fd          |
| `grep`  | ripgrep     |
| `du`    | dust        |
| `df`    | duf         |
| `top`   | bottom      |
| `cd`    | zoxide      |
| `lg`    | lazygit     |
| `ldc`   | lazydocker  |
| `k`     | kubectl     |

Also includes **Starship** prompt, **Atuin** (encrypted shell history) and **git-delta** (side-by-side diffs, `zdiff3` merge style).

---

## AI tools

| Tool        | Install method | Purpose                     |
|-------------|----------------|-----------------------------|
| claude      | install script | Claude Code CLI             |
| openclaude  | npm            | Claude API wrapper          |
| codex       | npm            | OpenAI Codex CLI            |
| comfyui     | distrobox      | Stable Diffusion GUI (NVIDIA + CUDA) |

### ComfyUI

Runs inside a distrobox container (Arch Linux) with NVIDIA GPU passthrough. The image is built with `buildah` and has `python-pytorch-opt-cuda` + `python-torchvision-cuda` baked in. The host's `~/comfyui/models/` directory is shared into the container automatically.

```sh
comfyui   # starts server + opens Chromium as PWA at http://127.0.0.1:8188
```

Closing the Chromium window automatically stops the ComfyUI server. A `.desktop` entry is also created for launching from the system app launcher.

Model directories created at `~/comfyui/models/`: `checkpoints`, `loras`, `vae`, `embeddings`, `controlnet`, `upscale_models`, `clip`, `diffusion_models`.

### Skills

Cloned from [DiegoBulhoes/claude](https://github.com/DiegoBulhoes/claude) into `~/vinny/skills` and symlinked into `~/.claude/skills/` and `~/.claude/agents/`.

| Category   | Skills                                              |
|------------|-----------------------------------------------------|
| IaC        | terraform, terragrunt, ansible, iac-review          |
| Kubernetes | kubernetes, helm, kustomize, gitops                 |
| Dev        | golang, rust                                        |
| Workflow   | explore, audit, prd, tech-spec, technical-docs      |
| Agents     | terraform-expert, ansible-expert, spec-writer, cloud-troubleshooter |

---

## MCP servers

Configured via `claude mcp add` (doesn't edit JSON directly — works even on a fresh Claude Code install):

| Server               | Transport | Notes                                  |
|----------------------|-----------|----------------------------------------|
| kubernetes-mcp-server | npx      | Read-only, uses `~/.kube/config`       |
| grafana              | uvx       | Set `grafana_url` and `grafana_token`  |
| cloudflare           | HTTP      | `https://mcp.cloudflare.com/mcp`       |

To set Grafana credentials at runtime:
```sh
ansible-playbook -i inventory/cachyos-niri.yml site.yml --tags ia \
  -e grafana_url=https://myinstance.grafana.net -e grafana_token=<token>
```

---

## Storage

- **ZRAM**: 4GB compressed swap in RAM (zstd, priority 100) — used before any disk swap
- **Snapper**: automatic Btrfs snapshots of `/` — 10 hourly, 7 daily, 1 weekly, 1 monthly, max 50 total
- **CoW disabled**: `/var/lib/docker` and `/var/lib/ollama` use `chattr +C` to avoid Btrfs CoW overhead

---

## VPN

- **WireGuard** (`wireguard-tools`) — tunnel config not included, add manually to `/etc/wireguard/`
- **Cloudflare WARP** (`cloudflare-warp-bin`) — `warp-svc` enabled on boot; register once after install:
  ```sh
  warp-cli register
  warp-cli connect
  ```

---

## Gaming

| Package | Purpose |
|---|---|
| `proton-cachyos` | CachyOS-optimized Proton for Heroic and non-Steam launchers |
| `proton-cachyos-slr` | CachyOS-optimized Proton for Steam (Steam Linux Runtime build) |
| `umu-launcher` | Run Proton outside of Steam (GOG, Epic, etc.) |
| `wine-cachyos-opt` | CachyOS-optimized Wine for Windows apps |
| `winetricks` / `protontricks` | Wine/Proton prefix configuration |
| `gamescope` | Valve Wayland micro-compositor for games |
| `mangohud` + `lib32-mangohud` | FPS/GPU/CPU overlay (toggle: `Shift+F12`) |
| `goverlay` | GUI to configure MangoHud |
| `heroic-games-launcher-bin` | Epic Games and GOG launcher |
| `lutris` | Multi-source game manager |
| `vulkan-tools` | Vulkan diagnostics |
| `sunshine` | Self-hosted game stream host for Moonlight (CachyOS repo) |

MangoHud config is deployed to `~/.config/MangoHud/MangoHud.conf`.  
Heroic version is controlled by `gaming_heroic_version` in `roles/gaming/defaults/main.yml`.

### Virtual display (Arch/CachyOS only)

The `virtual_display` role creates a headless 4K display via EDID firmware + kernel parameter, used as a dedicated Sunshine streaming output.

- Deploys a 4K EDID binary to `/usr/lib/firmware/edid/4k.bin` and bundles it into the initramfs
- Appends `drm.edid_firmware` + `video=` kernel params to all systemd-boot entries
- Configures Sunshine to capture the virtual connector
- Disables the virtual output in Niri by default (won't appear on desktop until activated)
- Deploys a `sunshine` fish function to toggle the display and start streaming:

```sh
sunshine on   # enables virtual display + starts Sunshine
sunshine off  # disables virtual display + stops Sunshine
```

---

## Virtualization

Installed via the `virtualization` role (tag: `devtools`).

| Package | Purpose |
|---|---|
| `qemu-full` / `qemu-kvm` | QEMU hypervisor |
| `libvirt` | Virtualization management API |
| `virt-manager` | GUI for managing VMs via libvirt |
| `gnome-boxes` | Simple GNOME VM manager |
| `virt-viewer` | Lightweight VM display client |
| `dnsmasq` | DHCP/DNS for virtual networks |
| `edk2-ovmf` | UEFI firmware for VMs |

The role also enables the `libvirtd` service and adds the user to the `libvirt` and `kvm` groups (re-login required after first run).

---

## Bootloader

The playbook assumes **systemd-boot** was picked during CachyOS installation.

The `bootloader` role:

1. Asserts `bootctl` reports systemd-boot as the current bootloader (fails fast if not).
2. Sets sane defaults in `/boot/loader/loader.conf` (timeout, console mode, editor disabled).
3. Runs `bootctl update` so the EFI binary on the ESP matches the installed `systemd` package — the `zz-sbctl` pacman hook re-signs it afterwards.

If you install with a different bootloader, skip with `--skip-tags bootloader`.

## Secure Boot

Uses `sbctl` to enroll custom keys **alongside** Microsoft certificates so that Windows/BitLocker on the second drive keeps working.

### Required BIOS step before running the playbook

`sbctl enroll-keys` requires the firmware to be in **Setup Mode** to write to the UEFI key database. This is a one-time prerequisite:

1. Reboot into BIOS/UEFI
2. Go to **Security → Secure Boot**
3. Select **Delete Secure Boot Keys** (or "Reset to Setup Mode") — this temporarily clears the keys
4. **Do not enable Secure Boot yet** — just save and boot back into Linux
5. Run the playbook — it enrolls your custom keys + Microsoft certificates automatically
6. Reboot into BIOS again and enable Secure Boot under **User Mode**

> **BitLocker note**: clearing keys in step 3 does not break BitLocker. The `--microsoft` flag re-enrolls the same Microsoft certificates, so Windows boots normally after step 6.

### What the playbook does

| Step | What happens | Idempotent? |
|---|---|---|
| Key creation | Creates keys in `/var/lib/sbctl/keys/` | Skipped if keys exist |
| Setup Mode assert | Fails with actionable message if firmware is not in Setup Mode during first run | First run only |
| Key enrollment | Enrolls custom + Microsoft keys into firmware | Skipped if already enrolled |
| Discover & register | Finds `*.efi` and `vmlinuz-*` under `/boot` and registers each with `sbctl sign -s` so files.json is populated | Always runs (idempotent) |
| Sign all | Re-signs every registered binary | Always runs (safe to re-run) |
| Verify | Fails the play if **any** binary is unsigned (strict) | Always runs |

Snapper snapshots are created before and after the setup — only on the first run.

The `sbctl` pacman hook auto-signs binaries on every kernel or systemd update.

---

## Niri — Keybinds

> `Mod` = Super key (Windows key)

### Applications

| Shortcut | Action |
|----------|--------|
| `Mod+Return` | Terminal (Alacritty + tmux) |
| `Mod+Space` | App launcher (noctalia) |
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
| `Mod+Shift+Escape` / `Mod+Shift+H` | Hotkey overlay |
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
ansible-playbook -i inventory/cachyos-niri.yml site.yml --tags keybinds
```
