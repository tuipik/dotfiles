#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

YAZI_SOURCE="$SCRIPT_DIR"
YAZI_TARGET="$HOME/.config/yazi"

mkdir -p "$HOME/.config"

if [ -L "$YAZI_TARGET" ]; then
    current_target="$(readlink -f "$YAZI_TARGET")"

    if [ "$current_target" = "$YAZI_SOURCE" ]; then
        echo "Yazi symlink already configured."
    else
        echo "Replacing existing Yazi symlink:"
        echo "  $YAZI_TARGET -> $current_target"
        rm "$YAZI_TARGET"
        ln -s "$YAZI_SOURCE" "$YAZI_TARGET"
    fi

elif [ -e "$YAZI_TARGET" ]; then
    backup="${YAZI_TARGET}.backup.$(date +%Y%m%d-%H%M%S)"

    echo "Backing up existing Yazi config:"
    echo "  $YAZI_TARGET -> $backup"

    mv "$YAZI_TARGET" "$backup"
    ln -s "$YAZI_SOURCE" "$YAZI_TARGET"

else
    ln -s "$YAZI_SOURCE" "$YAZI_TARGET"
fi

echo "Yazi config:"
ls -ld "$YAZI_TARGET"

if command -v ya >/dev/null 2>&1; then
    echo
    echo "Installing Yazi packages..."
    ya pkg install
else
    echo
    echo "Warning: 'ya' was not found."
    echo "Install Yazi first, then run:"
    echo "  ya pkg install"
fi

echo
echo "Done."
