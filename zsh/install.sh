#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=../lib/distro.sh
source "$DOTFILES_DIR/lib/distro.sh"

ZSHRC_SOURCE="$SCRIPT_DIR/.zshrc"
ZSHRC_TARGET="$HOME/.zshrc"

OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"
OH_MY_ZSH_ENTRYPOINT="$OH_MY_ZSH_DIR/oh-my-zsh.sh"

log() {
    printf '\n==> %s\n' "$1"
}

# ---------------------------------------------------------------------------
# Dependencies
# ---------------------------------------------------------------------------

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

ZSH_BIN="$(command -v zsh)"

# ---------------------------------------------------------------------------
# Oh My Zsh
# ---------------------------------------------------------------------------

log "Installing Oh My Zsh"

if [ ! -f "$OH_MY_ZSH_ENTRYPOINT" ]; then
    if [ -e "$OH_MY_ZSH_DIR" ]; then
        backup="${OH_MY_ZSH_DIR}.backup.$(date +%Y%m%d-%H%M%S)"

        echo "Incomplete Oh My Zsh installation found."
        echo "Backing it up to:"
        echo "  $backup"

        mv "$OH_MY_ZSH_DIR" "$backup"
    fi

    git clone \
        https://github.com/ohmyzsh/ohmyzsh.git \
        "$OH_MY_ZSH_DIR"
else
    echo "Oh My Zsh already installed."
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$OH_MY_ZSH_DIR/custom}"

# ---------------------------------------------------------------------------
# Plugins
# ---------------------------------------------------------------------------

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

# ---------------------------------------------------------------------------
# .zshrc
# ---------------------------------------------------------------------------

log "Configuring .zshrc"

if [ -L "$ZSHRC_TARGET" ]; then
    current_target="$(readlink -f "$ZSHRC_TARGET")"

    if [ "$current_target" = "$ZSHRC_SOURCE" ]; then
        echo ".zshrc symlink already configured."
    else
        rm "$ZSHRC_TARGET"
        ln -s "$ZSHRC_SOURCE" "$ZSHRC_TARGET"
    fi

elif [ -e "$ZSHRC_TARGET" ]; then
    backup="$ZSHRC_TARGET.backup.$(date +%Y%m%d-%H%M%S)"

    echo "Backing up existing .zshrc to:"
    echo "  $backup"

    mv "$ZSHRC_TARGET" "$backup"
    ln -s "$ZSHRC_SOURCE" "$ZSHRC_TARGET"

else
    ln -s "$ZSHRC_SOURCE" "$ZSHRC_TARGET"
fi

echo
echo "Configured:"
ls -ld "$ZSHRC_TARGET"

# ---------------------------------------------------------------------------
# Default shell
# ---------------------------------------------------------------------------

log "Configuring default shell"

CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"

if [ "$CURRENT_SHELL" = "$ZSH_BIN" ]; then
    echo "Zsh is already the default shell."
else
    echo "Current shell: $CURRENT_SHELL"
    echo "New shell:     $ZSH_BIN"

    if ! grep -Fxq "$ZSH_BIN" /etc/shells; then
        echo "Zsh is not listed in /etc/shells:"
        echo "  $ZSH_BIN"
        exit 1
    fi

    sudo chsh -s "$ZSH_BIN" "$USER"

    echo "Default shell changed to Zsh."
    echo "The change will apply on the next login."
fi

# ---------------------------------------------------------------------------
# Verification
# ---------------------------------------------------------------------------

log "Verifying installation"

if [ ! -f "$OH_MY_ZSH_ENTRYPOINT" ]; then
    echo "Oh My Zsh installation is incomplete."
    exit 1
fi

if [ ! -L "$ZSHRC_TARGET" ]; then
    echo ".zshrc symlink is missing."
    exit 1
fi

if [ "$(readlink -f "$ZSHRC_TARGET")" != "$ZSHRC_SOURCE" ]; then
    echo ".zshrc points to the wrong location."
    exit 1
fi

echo
echo "Zsh:"
zsh --version

echo
echo "Oh My Zsh:"
echo "  $OH_MY_ZSH_ENTRYPOINT"

echo
echo "Config:"
echo "  $ZSHRC_TARGET -> $(readlink "$ZSHRC_TARGET")"

echo
echo "Login shell:"
getent passwd "$USER" | cut -d: -f7

echo
echo "Done."
