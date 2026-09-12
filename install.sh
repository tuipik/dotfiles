#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() {
    printf '\n============================================================\n'
    printf '  %s\n' "$1"
    printf '============================================================\n'
}

run_installer() {
    local name="$1"
    local installer="$2"

    log "Installing $name"

    if [ ! -f "$installer" ]; then
        echo "Installer not found:"
        echo "  $installer"
        exit 1
    fi

    if [ ! -x "$installer" ]; then
        chmod +x "$installer"
    fi

    "$installer"
}

echo
echo "Dotfiles setup"
echo "Repository: $DOTFILES_DIR"

run_installer "Yazi"   "$DOTFILES_DIR/yazi/install.sh"
run_installer "Zsh"    "$DOTFILES_DIR/zsh/install.sh"
run_installer "Tmux"   "$DOTFILES_DIR/tmux/install.sh"
run_installer "Neovim" "$DOTFILES_DIR/nvim/install.sh"

log "Installation complete"

echo "Installed:"
echo "  Yazi"
echo "  Zsh"
echo "  Tmux"
echo "  Neovim"

echo
echo "Start a new shell to apply the complete environment:"
echo
echo "  exec zsh"
echo
