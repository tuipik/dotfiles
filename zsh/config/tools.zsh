export EDITOR=nvim

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.luarocks/bin:$PATH"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"

if [ -d "$PYENV_ROOT/bin" ]; then
    export PATH="$PYENV_ROOT/bin:$PATH"
fi

if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init - zsh)"

    if pyenv commands | grep -qx virtualenv-init; then
        eval "$(pyenv virtualenv-init -)"
    fi
fi

# NVM
export NVM_DIR="$HOME/.nvm"

[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

[ -s "$NVM_DIR/bash_completion" ] && \
    source "$NVM_DIR/bash_completion"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# zoxide
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi
