#!/bin/bash
# Wrapper invoked by Steam Non-Steam shortcuts created by Heroic-in-sandbox.
# Routes through heroic-launch.sh which sets the AppImage env vars (APPDIR,
# LD_LIBRARY_PATH, XDG_DATA_DIRS, GSETTINGS_SCHEMA_DIR) — calling heroic
# directly leaves these unset and the game window ends up invisible/1x1.
# Strips --no-gui (game launched in --no-gui mode has no activation context
# and renders at 1x1) and --no-sandbox (heroic-launch.sh adds it).
ARGS=()
for arg in "$@"; do
  case "$arg" in
    --no-gui|--no-sandbox) continue ;;
  esac
  ARGS+=("$arg")
done
exec distrobox enter games-sandbox -- /home/vinny/games-sandbox/home/heroic-launch.sh "${ARGS[@]}"
