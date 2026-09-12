#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

NVIM_SOURCE="$SCRIPT_DIR"
NVIM_TARGET="$HOME/.config/nvim"

NVIM_INSTALL_DIR="/opt/nvim-linux-x86_64"
NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"

log() {
    printf '\n==> %s\n' "$1"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ---------------------------------------------------------------------------
# System dependencies
# ---------------------------------------------------------------------------

log "Installing system dependencies"

if ! command_exists apt-get; then
    echo "This installer currently supports Ubuntu/Debian only."
    exit 1
fi

sudo apt-get update

sudo apt-get install -y \
    ca-certificates \
    curl \
    git \
    build-essential \
    unzip \
    ripgrep \
    fd-find \
    npm

# Ubuntu/Debian provides fd as `fdfind`.
if ! command_exists fd && command_exists fdfind; then
    sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd
fi

# ---------------------------------------------------------------------------
# Neovim
# ---------------------------------------------------------------------------

log "Installing latest stable Neovim"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

curl -fL "$NVIM_URL" \
    -o "$tmp_dir/nvim-linux-x86_64.tar.gz"

sudo rm -rf "$NVIM_INSTALL_DIR"

sudo tar \
    -C /opt \
    -xzf "$tmp_dir/nvim-linux-x86_64.tar.gz"

sudo ln -sf \
    "$NVIM_INSTALL_DIR/bin/nvim" \
    /usr/local/bin/nvim

log "Installed Neovim"

/usr/local/bin/nvim --version | head -3

# ---------------------------------------------------------------------------
# Neovim configuration
# ---------------------------------------------------------------------------

log "Configuring Neovim"

mkdir -p "$HOME/.config"

if [ -L "$NVIM_TARGET" ]; then
    current_target="$(readlink -f "$NVIM_TARGET")"

    if [ "$current_target" = "$NVIM_SOURCE" ]; then
        echo "Neovim symlink already configured."
    else
        echo "Replacing existing Neovim symlink:"
        echo "  $NVIM_TARGET -> $current_target"

        rm "$NVIM_TARGET"
        ln -s "$NVIM_SOURCE" "$NVIM_TARGET"
    fi

elif [ -e "$NVIM_TARGET" ]; then
    backup="${NVIM_TARGET}.backup.$(date +%Y%m%d-%H%M%S)"

    echo "Backing up existing Neovim config:"
    echo "  $NVIM_TARGET -> $backup"

    mv "$NVIM_TARGET" "$backup"
    ln -s "$NVIM_SOURCE" "$NVIM_TARGET"

else
    ln -s "$NVIM_SOURCE" "$NVIM_TARGET"
fi

echo
echo "Configured:"
ls -ld "$NVIM_TARGET"

# ---------------------------------------------------------------------------
# Plugins
# ---------------------------------------------------------------------------

log "Installing Neovim plugins"

/usr/local/bin/nvim --headless "+Lazy! sync" +qa

# ---------------------------------------------------------------------------
# Verification
# ---------------------------------------------------------------------------

log "Verifying installation"

/usr/local/bin/nvim --headless "+qa"

echo
echo "Neovim:"
/usr/local/bin/nvim --version | head -1

echo
echo "Configuration:"
ls -ld "$NVIM_TARGET"

echo
echo "If this shell previously used another Neovim installation,"
echo "run:"
echo
echo "  rehash"

echo
echo "Done."
