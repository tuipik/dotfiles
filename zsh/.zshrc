export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="gnzh"

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

ZSH_CONFIG_DIR="$HOME/dotfiles/zsh/config"

for config in "$ZSH_CONFIG_DIR"/*.zsh; do
    [ -r "$config" ] && source "$config"
done
