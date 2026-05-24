#!/usr/bin/env bash
# Bubblewrap wrapper for untrusted game executables.
# Run inside the games-sandbox distrobox.
# Heroic: set this as the "Wrapper" in game advanced settings.

set -euo pipefail

PROTON="$HOME/.config/heroic/tools/proton/proton-cachyos/proton"

# Modo run: bwrap-game.sh --run /path/to/game.exe [prefix-name]
# Roda um exe já instalado usando o prefix em $HOME/wine-prefixes/<prefix-name>.
if [[ "${1:-}" == "--run" ]]; then
  shift
  EXE="$1"; shift
  PREFIX_NAME="${1:-$(basename "$(dirname "$EXE")")}"
  export WINEPREFIX="$HOME/wine-prefixes/$PREFIX_NAME"
  exec "$0" "$PROTON" run "$EXE"
fi

# Modo instalador: bwrap-game.sh --install /path/to/setup.exe [prefix-name]
# O Wine prefix é criado em $HOME/wine-prefixes/<prefix-name> (persiste fora do tmpfs).
# Se prefix-name for omitido, usa o nome do exe sem extensão.
if [[ "${1:-}" == "--install" ]]; then
  shift
  INSTALLER="$1"; shift
  PREFIX_NAME="${1:-$(basename "$INSTALLER" .exe)}"
  export WINEPREFIX="$HOME/wine-prefixes/$PREFIX_NAME"
  mkdir -p "$WINEPREFIX"
  exec "$0" "$PROTON" run "$INSTALLER"
fi

UID_VAL=$(id -u)
GAME_DIR="$HOME/games"
WINE_DIR="$HOME/wine-prefixes"
HEROIC_TOOLS="$HOME/.config/heroic/tools"     # proton, umu runtime
HEROIC_PREFIXES="$HOME/Games/Heroic/Prefixes" # wine prefixes gerenciados pelo heroic
HEROIC_STATE="$HOME/.local/state/Heroic"      # logs do heroic
UMU_DIR="$HOME/.local/share/umu"              # steamrt3 baixado pelo umu
CACHE_DIR="$HOME/.cache"                      # cache de proton/wine
WAYLAND_SOCK="/run/user/${UID_VAL}/${WAYLAND_DISPLAY:-wayland-0}"
PIPEWIRE_SOCK="/run/user/${UID_VAL}/pipewire-0"
PULSE_DIR="/run/user/${UID_VAL}/pulse"

BWRAP_ARGS=(
  # Bind todo o container read-only como base
  --ro-bind / /

  # Bloquear saídas para o host real
  # /run/host expõe o filesystem do host — bloqueamos só /home e /root
  # mas deixamos /run/host/usr para que o pressure-vessel ache as libs NVIDIA do host
  --tmpfs /run/host/home
  --tmpfs /run/host/root
  --tmpfs /run/host/tmp
  --tmpfs /home            # distrobox também monta /home/vinny (home real do host)
  --tmpfs /tmp

  # Ferramentas do Heroic (confiáveis — proton, umu, prefixes)
  --bind "$HEROIC_TOOLS"    "$HEROIC_TOOLS"
  --bind "$HEROIC_PREFIXES" "$HEROIC_PREFIXES"
  --bind "$HEROIC_STATE"    "$HEROIC_STATE"
  --bind "$UMU_DIR"         "$UMU_DIR"
  --bind "$CACHE_DIR"       "$CACHE_DIR"

  # Dados do jogo
  --bind "$GAME_DIR" "$GAME_DIR"
  --bind "$WINE_DIR" "$WINE_DIR"

  # Reexpor dentro do home falso para que o jogo encontre seus arquivos
  --bind "$GAME_DIR"  "$HOME/games"
  --bind "$WINE_DIR"  "$HOME/wine-prefixes"

  # Proc e dev (necessários para Wine/Proton)
  --proc /proc
  --dev /dev
  --dev-bind /dev/dri /dev/dri

  # /dev/input para gamepads/joysticks (--dev cria tmpfs mínimo sem input devices).
  --dev-bind-try /dev/input /dev/input
  --ro-bind-try /run/udev /run/udev

  # NVIDIA — devices proprietários necessários para Vulkan/OpenGL
  --dev-bind-try /dev/nvidia0          /dev/nvidia0
  --dev-bind-try /dev/nvidiactl        /dev/nvidiactl
  --dev-bind-try /dev/nvidia-modeset   /dev/nvidia-modeset
  --dev-bind-try /dev/nvidia-uvm       /dev/nvidia-uvm
  --dev-bind-try /dev/nvidia-uvm-tools /dev/nvidia-uvm-tools

  # pressure-vessel gera o ICD com path "/run/host/usr/lib/libGLX_nvidia.so.VERSION".
  # Dentro do container do pressure-vessel, /run/host/ aponta para a raiz do nosso bwrap,
  # não para o Arch host. Por isso bindamos /run/host/usr/lib (libs reais do Arch) sobre
  # /usr/lib/nvidia-host, substituindo os symlinks por acesso direto ao binário.
  --ro-bind /run/host/usr/lib /usr/lib/nvidia-host

  # Expõe proton-cachyos e outros Proton instalados no host onde o umu auto-detecta.
  --ro-bind-try /run/host/usr/share/steam/compatibilitytools.d \
                /usr/share/steam/compatibilitytools.d

  # Substituir /run/user/UID por tmpfs vazio — wine precisa escrever aqui
  # (wineserver cria sockets em /run/user/UID/wine/server-*)
  --tmpfs "/run/user/${UID_VAL}"

  # Remontar só os sockets necessários dentro do tmpfs
  --bind "$WAYLAND_SOCK" "$WAYLAND_SOCK"
  --bind "/run/user/${UID_VAL}/bus" "/run/user/${UID_VAL}/bus"
)

# Áudio — monta o que existir
if [[ -S "$PIPEWIRE_SOCK" ]]; then
  BWRAP_ARGS+=(--bind "$PIPEWIRE_SOCK" "$PIPEWIRE_SOCK")
fi
if [[ -d "$PULSE_DIR" ]]; then
  BWRAP_ARGS+=(--bind "$PULSE_DIR" "$PULSE_DIR")
fi

BWRAP_ARGS+=(
  --setenv WAYLAND_DISPLAY "${WAYLAND_DISPLAY:-wayland-0}"
  --setenv XDG_RUNTIME_DIR "/run/user/${UID_VAL}"
  --setenv HOME "$HOME"
  --setenv LD_LIBRARY_PATH "/usr/lib/nvidia-host:${LD_LIBRARY_PATH:-}"
  --setenv WINEPREFIX "${WINEPREFIX:-}"

  --die-with-parent
)

exec bwrap "${BWRAP_ARGS[@]}" "$@"
