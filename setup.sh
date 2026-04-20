#!/usr/bin/env bash
set -euo pipefail

install_arch() {
    sudo pacman -Sy --noconfirm ansible-core
    ansible-galaxy collection install community.general kewlfft.aur
}

install_fedora() {
    sudo dnf install -y ansible-core
    ansible-galaxy collection install community.general kewlfft.aur
}

install_ubuntu() {
    sudo apt update
    sudo apt install -y ansible
    ansible-galaxy collection install community.general kewlfft.aur
}

case "$(. /etc/os-release && echo "$ID")" in
    cachyos|arch|endeavouros|manjaro)
        install_arch ;;
    fedora)
        install_fedora ;;
    ubuntu|debian|linuxmint|pop)
        install_ubuntu ;;
    *)
        echo "Distro não suportada. Instale ansible-core manualmente."
        exit 1 ;;
esac

case "$(. /etc/os-release && echo "$ID")" in
    cachyos)        INVENTORY="inventory/cachyos-niri.yml" ;;
    arch|endeavouros|manjaro) INVENTORY="inventory/archlinux.yml" ;;
    fedora)         INVENTORY="inventory/fedora.yml" ;;
    ubuntu|debian|linuxmint|pop) INVENTORY="inventory/ubuntu.yml" ;;
esac

cat <<EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Ansible pronto. Sugestão de instalação em estágios
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Estágio 1 — Crítico (storage + secure boot)
  Rápido. Faça isso primeiro, especialmente em instalação nova.

    ansible-playbook -i $INVENTORY site.yml --tags storage,security

  Estágio 2 — Base (ferramentas, desktop, devtools)
  Instala pacotes, niri, shell, docker, mise, etc.

    ansible-playbook -i $INVENTORY site.yml --tags tools,cachyos,devtools,gaming

  Estágio 3 — IA (Claude Code, MCPs, Codex)

    ansible-playbook -i $INVENTORY site.yml --tags ia

  Estágio 3b — ComfyUI (opcional, demora bastante)
  Só quando precisar — baixa modelos e dependências pesadas.

    ansible-playbook -i $INVENTORY site.yml --tags comfyui

  Tudo de uma vez (não recomendado na primeira instalação):

    ansible-playbook -i $INVENTORY site.yml

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Ou instale por componente (--tags):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  storage   → ZRAM, snapper, CoW desabilitado
  security  → Secure Boot (sbctl + chaves Microsoft)
  tools     → pacotes base, shell, tmux, chromium, slack, 1password, vpn
  cachyos   → paru + pacotes AUR (Arch/CachyOS)
  devtools  → mise, terraform, kubectl, docker, jetbrains
  niri      → keybinds e tema GTK
  gaming    → Heroic, Lutris, MangoHud, Proton, gamepad
  ia        → Claude Code, Codex, MCPs, skills
  comfyui   → ComfyUI isolado (demorado)

  Exemplo:
    ansible-playbook -i $INVENTORY site.yml --tags devtools,tools
    ansible-playbook -i $INVENTORY site.yml --skip-tags gaming,comfyui

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
