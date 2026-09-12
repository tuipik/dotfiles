#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=../lib/distro.sh
source "$DOTFILES_DIR/lib/distro.sh"

YAZI_SOURCE="$SCRIPT_DIR"
YAZI_TARGET="$HOME/.config/yazi"

log() {
    printf '\n==> %s\n' "$1"
}

ok() {
    printf '  [OK] %s\n' "$1"
}

warn() {
    printf '  [WARN] %s\n' "$1"
}

# ---------------------------------------------------------------------------
# Base dependencies
# ---------------------------------------------------------------------------

log "Installing base dependencies"

case "$DISTRO_FAMILY" in
    debian)
        install_packages \
            ca-certificates \
            curl \
            gnupg \
            fd-find \
            ripgrep \
            fzf \
            zoxide \
            jq \
            poppler-utils

        # Ubuntu/Debian packages fd as `fdfind`, while Yazi expects `fd`.
        if ! command_exists fd && command_exists fdfind; then
            log "Creating fd compatibility symlink"
            sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd
        fi
        ;;

    arch)
        install_packages \
            ca-certificates \
            curl \
            fd \
            ripgrep \
            fzf \
            zoxide \
            jq \
            poppler
        ;;
esac

# ---------------------------------------------------------------------------
# Yazi
# ---------------------------------------------------------------------------

if ! command_exists yazi || ! command_exists ya; then
    log "Installing Yazi"

    case "$DISTRO_FAMILY" in
        debian)
            curl -fsSL https://yazi-rs.github.io/builds/yazi-keyring.gpg \
                | sudo tee /usr/share/keyrings/yazi-keyring.gpg >/dev/null

            echo \
                'deb [signed-by=/usr/share/keyrings/yazi-keyring.gpg] https://yazi-rs.github.io/builds/ stable main' \
                | sudo tee /etc/apt/sources.list.d/yazi.list >/dev/null

            # A new repository was added, so force a fresh APT index update.
            DOTFILES_APT_UPDATED=0
            refresh_package_index

            install_packages yazi
            ;;

        arch)
            install_packages yazi
            ;;
    esac
else
    ok "Yazi already installed: $(yazi --version | head -n1)"
fi

# ---------------------------------------------------------------------------
# Glow
# ---------------------------------------------------------------------------

if ! command_exists glow; then
    log "Installing Glow"

    case "$DISTRO_FAMILY" in
        debian)
            sudo mkdir -p /etc/apt/keyrings

            curl -fsSL https://repo.charm.sh/apt/gpg.key \
                | sudo gpg --dearmor --yes -o /etc/apt/keyrings/charm.gpg

            echo \
                'deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *' \
                | sudo tee /etc/apt/sources.list.d/charm.list >/dev/null

            # A new repository was added, so force a fresh APT index update.
            DOTFILES_APT_UPDATED=0
            refresh_package_index

            install_packages glow
            ;;

        arch)
            install_packages glow
            ;;
    esac
else
    ok "Glow already installed: $(glow --version 2>/dev/null | head -n1 || echo installed)"
fi

# ---------------------------------------------------------------------------
# Yazi config symlink
# ---------------------------------------------------------------------------

log "Configuring Yazi"

mkdir -p "$HOME/.config"

if [ -L "$YAZI_TARGET" ]; then
    current_target="$(readlink -f "$YAZI_TARGET")"

    if [ "$current_target" = "$YAZI_SOURCE" ]; then
        ok "Yazi symlink already configured"
    else
        warn "Replacing Yazi symlink: $current_target"
        rm "$YAZI_TARGET"
        ln -s "$YAZI_SOURCE" "$YAZI_TARGET"
    fi

elif [ -e "$YAZI_TARGET" ]; then
    backup="${YAZI_TARGET}.backup.$(date +%Y%m%d-%H%M%S)"

    warn "Existing Yazi config found"
    echo "       Backup: $backup"

    mv "$YAZI_TARGET" "$backup"
    ln -s "$YAZI_SOURCE" "$YAZI_TARGET"

else
    ln -s "$YAZI_SOURCE" "$YAZI_TARGET"
fi

# ---------------------------------------------------------------------------
# Yazi plugins
# ---------------------------------------------------------------------------

log "Installing Yazi plugins"

ya pkg install

# ---------------------------------------------------------------------------
# Verification
# ---------------------------------------------------------------------------

log "Verifying installation"

FAILED=0

check_command() {
    local command_name="$1"
    local description="${2:-$1}"

    if command_exists "$command_name"; then
        ok "$description: $(command -v "$command_name")"
    else
        printf '  [FAILED] %s\n' "$description"
        FAILED=1
    fi
}

check_command yazi "Yazi"
check_command ya "Yazi package manager"
check_command fd "fd"
check_command rg "ripgrep"
check_command fzf "fzf"
check_command zoxide "zoxide"
check_command jq "jq"
check_command pdftotext "pdftotext"
check_command glow "Glow"

echo

if [ -L "$YAZI_TARGET" ]; then
    ok "$YAZI_TARGET -> $(readlink "$YAZI_TARGET")"
else
    printf '  [FAILED] Yazi config symlink\n'
    FAILED=1
fi

echo

if [ "$FAILED" -eq 0 ]; then
    echo "Yazi environment installed successfully."
    echo
    yazi --version
else
    echo "Installation finished with errors."
    exit 1
fi
