eval "$(/usr/local/bin/brew shellenv)"
export PATH="/usr/local/opt/php@8.3/sbin:$PATH"
export PATH="$PATH:$HOME/Documents/app-dev/flutter/bin"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export PATH="/usr/local/opt/icu4c@76/bin:$PATH"
export PATH="/usr/local/opt/icu4c@76/sbin:$PATH"
export LDFLAGS="-L/usr/local/opt/icu4c@76/lib"
export CPPFLAGS="-I/usr/local/opt/icu4c@76/include"
export PKG_CONFIG_PATH="/usr/local/opt/icu4c@76/lib/pkgconfig"
export PATH="/usr/local/opt/icu4c@76/bin:$PATH"
export PATH="/usr/local/opt/icu4c@76/sbin:$PATH"
export PATH="$PATH:$HOME/develop/flutter/bin"
export LDFLAGS="-L/usr/local/opt/icu4c@76/lib"
export CPPFLAGS="-I/usr/local/opt/icu4c@76/include"
export PKG_CONFIG_PATH="/usr/local/opt/icu4c@76/lib/pkgconfig"
export PATH="$PATH:$HOME/.pub-cache/bin"
export PATH="$PATH:$HOME/.pub-cache/bin:$HOME/.dart/pub-cache/bin"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
