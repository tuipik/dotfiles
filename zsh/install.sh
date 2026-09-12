#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=../lib/distro.sh
source "$DOTFILES_DIR/lib/distro.sh"

ZSHRC_SOURCE="$SCRIPT_DIR/.zshrc"
ZSHRC_TARGET="$HOME/.zshrc"

log() {
    printf '\n==> %s\n' "$1"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

log "Installing Zsh dependencies"

if ! command_exists git; then
    install_packages git
else
    echo "Git already installed: $(git --version)"
fi

if ! command_exists zsh; then
    install_packages zsh
else
    echo "Zsh already installed: $(zsh --version)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

log "Installing Zsh plugins"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone \
        https://github.com/zsh-users/zsh-autosuggestions \
        "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone \
        https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

log "Configuring .zshrc"

if [ -L "$ZSHRC_TARGET" ]; then
    rm "$ZSHRC_TARGET"

elif [ -e "$ZSHRC_TARGET" ]; then
    backup="$ZSHRC_TARGET.backup.$(date +%Y%m%d-%H%M%S)"
    echo "Backing up existing .zshrc to:"
    echo "  $backup"

    mv "$ZSHRC_TARGET" "$backup"
fi

ln -s "$ZSHRC_SOURCE" "$ZSHRC_TARGET"

echo
echo "Configured:"
ls -ld "$ZSHRC_TARGET"

echo
echo "Done."
