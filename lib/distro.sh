#!/usr/bin/env bash

# Shared Linux distribution and package-manager helpers.
#
# Supported families:
#   debian: Ubuntu, Debian
#   arch:   Arch Linux, Manjaro

if [[ -n "${DOTFILES_DISTRO_SH_LOADED:-}" ]]; then
    return 0 2>/dev/null || exit 0
fi

DOTFILES_DISTRO_SH_LOADED=1

# ---------------------------------------------------------------------------
# Distribution detection
# ---------------------------------------------------------------------------

if [[ ! -r /etc/os-release ]]; then
    echo "Cannot detect Linux distribution: /etc/os-release not found." >&2
    return 1 2>/dev/null || exit 1
fi

# shellcheck disable=SC1091
source /etc/os-release

DISTRO_ID="${ID:-unknown}"
DISTRO_NAME="${PRETTY_NAME:-${NAME:-$DISTRO_ID}}"
DISTRO_ID_LIKE="${ID_LIKE:-}"

case "$DISTRO_ID" in
    ubuntu|debian)
        DISTRO_FAMILY="debian"
        ;;

    arch|manjaro)
        DISTRO_FAMILY="arch"
        ;;

    *)
        if [[ " $DISTRO_ID_LIKE " == *" debian "* ]]; then
            DISTRO_FAMILY="debian"
        elif [[ " $DISTRO_ID_LIKE " == *" arch "* ]]; then
            DISTRO_FAMILY="arch"
        else
            echo "Unsupported Linux distribution: $DISTRO_NAME" >&2
            echo "Supported distributions: Ubuntu, Debian, Arch Linux, Manjaro." >&2
            return 1 2>/dev/null || exit 1
        fi
        ;;
esac

readonly DISTRO_ID
readonly DISTRO_NAME
readonly DISTRO_ID_LIKE
readonly DISTRO_FAMILY

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

print_distro_info() {
    echo "Distribution: $DISTRO_NAME"
    echo "Family:       $DISTRO_FAMILY"
}

# ---------------------------------------------------------------------------
# Package manager
# ---------------------------------------------------------------------------

refresh_package_index() {
    case "$DISTRO_FAMILY" in
        debian)
            if [[ "${DOTFILES_APT_UPDATED:-0}" == "1" ]]; then
                return 0
            fi

            sudo apt-get update
            export DOTFILES_APT_UPDATED=1
            ;;

        arch)
            # Do not run `pacman -Sy` here.
            #
            # Arch-based systems do not support partial upgrades.
            # Package database synchronization should happen together
            # with a full system upgrade (`pacman -Syu`), outside this
            # dotfiles installer.
            return 0
            ;;
    esac
}

install_packages() {
    if [[ "$#" -eq 0 ]]; then
        return 0
    fi

    case "$DISTRO_FAMILY" in
        debian)
            refresh_package_index
            sudo apt-get install -y "$@"
            ;;

        arch)
            sudo pacman -S --needed --noconfirm "$@"
            ;;
    esac
}
