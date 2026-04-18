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

echo ""
echo "Ansible pronto. Rode com:"
echo "  ansible-playbook -i inventory/cachyos-niri.yml site.yml"
