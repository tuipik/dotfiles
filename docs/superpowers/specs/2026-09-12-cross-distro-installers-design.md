# Cross-Distro Dotfiles Installers Design

## Goal

Make the dotfiles installation work consistently on:

- Ubuntu
- Debian
- Arch Linux
- Manjaro

The complete setup must still be installable with:

```bash
~/dotfiles/install.sh
```

Individual component installers must continue to work independently.

Architecture

Distribution-specific package management is centralized in:

lib/distro.sh

The file detects the Linux distribution and exposes a common package installation interface.

Supported distribution families:

Ubuntu ─┐
Debian ─┴─> debian ─> apt-get

Arch ───┐
Manjaro ┴─> arch ───> pacman

The component installers remain responsible for choosing the appropriate package names for each family.

This avoids hiding package-name differences behind a complicated abstraction.

Repository Structure
dotfiles/
├── install.sh
├── lib/
│   └── distro.sh
├── yazi/
│   └── install.sh
├── zsh/
│   └── install.sh
├── tmux/
│   └── install.sh
└── nvim/
    └── install.sh

distro.sh Responsibilities

lib/distro.sh:

reads /etc/os-release;
detects Ubuntu, Debian, Arch Linux, and Manjaro;
maps them to debian or arch;
exposes distribution metadata;
exposes install_packages;
exposes package database refresh behavior where needed;
fails immediately on unsupported distributions.

It must not contain component-specific package lists.

Root Installer

install.sh remains an orchestrator.

It:

loads distribution detection;
prints the detected distribution and family;
fails before making changes if the distribution is unsupported;
runs Yazi, Zsh, Tmux, and Neovim installers sequentially.

It does not install component dependencies itself.

Zsh

Zsh installation uses the common package interface.

Package requirements are essentially identical across the supported families.

Oh My Zsh and its plugins continue to be installed directly from their Git repositories.

Existing .zshrc backup and symlink behavior remains unchanged.

Tmux

Tmux installation uses the common package interface.

Existing .tmux.conf backup and symlink behavior remains unchanged.

Neovim

Neovim itself is not installed from apt or pacman.

The installer continues to install the official latest stable Neovim release into:

/opt/nvim-linux-x86_64

with:

/usr/local/bin/nvim

pointing to it.

Only system dependencies differ between distribution families.

Examples:

Debian/Ubuntu    Arch/Manjaro
---------------  -------------
build-essential  base-devel
fd-find          fd

The existing Lazy bootstrap, configuration symlink, and verification remain unchanged.

Yazi

Yazi has the largest distribution-specific difference.

Debian family

Keep:

official Yazi APT repository;
Charm APT repository for Glow;
Debian-specific fdfind compatibility symlink.
Arch family

Use Arch/Manjaro packages where available through pacman.

Do not configure Debian APT repositories.

The Yazi configuration symlink, plugin installation through ya pkg install, and verification remain common.

Idempotency

Every installer must remain safe to execute multiple times.

A repeated root installation must:

not destroy an existing correct symlink;
not unnecessarily reinstall manually managed configuration;
not duplicate package repositories;
preserve existing configuration backups;
finish successfully on an already configured machine.
Unsupported Systems

Other distributions such as Fedora, openSUSE, NixOS, and Alpine are not supported yet.

The installer must explicitly fail instead of guessing how to install packages.

Validation

Validation happens in two stages:

Run the complete installer on the existing Ubuntu development server.
Run the same complete installer on Arch Linux or Manjaro.

For each system verify:

zsh
tmux
yazi
ya
glow
nvim

and confirm all configuration symlinks point into ~/dotfiles.

The second execution of:

~/dotfiles/install.sh

must also complete successfully.
