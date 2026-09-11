#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TMUX_SOURCE="$SCRIPT_DIR/.tmux.conf"
TMUX_TARGET="$HOME/.tmux.conf"

log() {
    printf '\n==> %s\n' "$1"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ---------------------------------------------------------------------------
# tmux
# ---------------------------------------------------------------------------

log "Installing tmux"

if ! command_exists tmux; then
    sudo apt-get update
    sudo apt-get install -y tmux
else
    echo "tmux already installed: $(tmux -V)"
fi

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

log "Configuring tmux"

if [ -L "$TMUX_TARGET" ]; then
    current_target="$(readlink -f "$TMUX_TARGET")"

    if [ "$current_target" = "$TMUX_SOURCE" ]; then
        echo "tmux symlink already configured."
    else
        echo "Replacing existing tmux symlink:"
        echo "  $TMUX_TARGET -> $current_target"

        rm "$TMUX_TARGET"
        ln -s "$TMUX_SOURCE" "$TMUX_TARGET"
    fi

elif [ -e "$TMUX_TARGET" ]; then
    backup="${TMUX_TARGET}.backup.$(date +%Y%m%d-%H%M%S)"

    echo "Backing up existing tmux config:"
    echo "  $TMUX_TARGET -> $backup"

    mv "$TMUX_TARGET" "$backup"
    ln -s "$TMUX_SOURCE" "$TMUX_TARGET"

else
    ln -s "$TMUX_SOURCE" "$TMUX_TARGET"
fi

echo
echo "Configured:"
ls -ld "$TMUX_TARGET"

# ---------------------------------------------------------------------------
# Verification
# ---------------------------------------------------------------------------

log "Verifying installation"

tmux -V

echo
echo "Done."
