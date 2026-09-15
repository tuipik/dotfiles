export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="gnzh"

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

DOTFILES_DIR="${${(%):-%N}:A:h:h}"
ZSH_CONFIG_DIR="$DOTFILES_DIR/zsh/config"

for config in "$ZSH_CONFIG_DIR"/*.zsh; do
    [ -r "$config" ] && source "$config"
done
