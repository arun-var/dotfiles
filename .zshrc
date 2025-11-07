# ~~~~~~~~~~~~~~~ Environment Variables ~~~~~~~~~~~~~~~~~~~~~~~~

# Set to superior editing mode
set -o vi

export VISUAL=nvim
export EDITOR=nvim
# Use different TERM settings based on OS
if [[ "$OSTYPE" == darwin* ]]; then
    export TERM="xterm-256color"
else
    export TERM="tmux-256color"
fi

# Set default browser based on OS
if [[ "$OSTYPE" == darwin* ]]; then
    export BROWSER="open"
else
    export BROWSER="firefox"
fi

# Directories
export REPOS="$HOME/warzone/repos"
export GITUSER="arun-var"
export GHREPOS="$REPOS/github.com/$GITUSER"
export DOTFILES="$GHREPOS/dotfiles"
export SCRIPTS="$DOTFILES/scripts"
export ICLOUD="$HOME/icloud"

# Go configuration
export GOBIN="$HOME/.local/bin"
export GOPRIVATE="github.com/$GITUSER/*,gitlab.com/$GITUSER/*"
export GOPATH="$HOME/go/"

# ~~~~~~~~~~~~~~~ Path configuration ~~~~~~~~~~~~~~~~~~~~~~~~

setopt extended_glob null_glob

# OS-specific paths
if [[ "$OSTYPE" == darwin* ]]; then
    EXTRA_PATHS=(
        /usr/local/bin
        /usr/local/MacGPG2/bin
        /opt/homebrew/bin
        /Users/$USER/.asdf/shims/
    )
else
    EXTRA_PATHS=(
        /usr/local/bin
        /home/$USER/.asdf/shims/
        /opt/nvim-linux64/bin/
    )
fi

path=(
    $path                           # Keep existing PATH entries
    $HOME/bin
    /bin
    $HOME/.local/bin
    $SCRIPTS
    $HOME/.rd/bin                   # Rancher Desktop
    /home/vscode/.local/bin         # Dev Container Specifics
    /root/.local/bin                # Dev Container Specifics
    $EXTRA_PATHS
)

# Remove duplicate entries and non-existent directories
typeset -U path
path=($^path(N-/))

export PATH

# ~~~~~~~~~~~~~~~ SSH ~~~~~~~~~~~~~~~~~~~~~~~~

# Using GPG + YubiKey for ssh.
# Don't execute when in dev container
if [[ -z "$REMOTE_CONTAINERS" && -z "$CODESPACES" && -z "$DEVCONTAINER_TYPE" ]]; then
    export GPG_TTY="$(tty)"
    unset SSH_AGENT_PID

    if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
        export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    fi

    gpgconf --launch gpg-agent
    gpg-connect-agent updatestartuptty /bye > /dev/null 2>&1
fi

# ~~~~~~~~~~~~~~~ Package Manager Integration ~~~~~~~~~~~~~~~~~~~~~~~~

# Homebrew integration
if [[ "$OSTYPE" == darwin* ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null)"
elif [ -d "/home/linuxbrew/.linuxbrew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# direnv integration
if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook zsh)"
fi

# ~~~~~~~~~~~~~~~ History ~~~~~~~~~~~~~~~~~~~~~~~~

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

setopt HIST_IGNORE_SPACE  # Don't save when prefixed with space
setopt HIST_IGNORE_DUPS   # Don't save duplicate lines
setopt SHARE_HISTORY      # Share history between sessions

# ~~~~~~~~~~~~~~~ Prompt ~~~~~~~~~~~~~~~~~~~~~~~~

PURE_GIT_PULL=0

# OS-specific pure-prompt configuration
if [[ "$OSTYPE" == darwin* ]]; then
    fpath+=("$(brew --prefix)/share/zsh/site-functions")
else
    fpath+=($HOME/.zsh/pure)
fi

fpath+=($HOME/.zsh/pure)
autoload -U promptinit; promptinit
prompt pure

# ~~~~~~~~~~~~~~~ Aliases ~~~~~~~~~~~~~~~~~~~~~~~~

alias v=nvim
alias vim=nvim
alias scripts='cd $SCRIPTS'
alias cdblog="cd ~/websites/blog"
alias c="clear"
alias icloud="cd \$ICLOUD"

# Repos
alias dot='cd $GHREPOS/dotfiles'
alias repos='cd $REPOS'
alias ghrepos='cd $GHREPOS'
alias gr='ghrepos'
alias cdgo='cd $GHREPOS/go/'

# ls commands based on OS
if [[ "$OSTYPE" == darwin* ]]; then
    alias ls='ls -G'
else
    alias ls='ls --color=auto'
fi
alias la='ls -lathr'

# finds all files recursively and sorts by last modification, ignore hidden files
alias lastmod='find . -type f -not -path "*/\.*" -exec ls -lrt {} +'

alias t='tmux'
alias e='exit'

# Package manager aliases based on OS
if [[ "$OSTYPE" == darwin* ]]; then
    alias update='brew update && brew upgrade'
else
    alias syu='sudo pacman -Syu'
fi

# Azure
alias sub='az account set -s'

# Git
alias gp='git pull'
alias gs='git status'
alias lg='lazygit'

# Kubernetes
alias k='kubectl'
alias kgp='kubectl get pods'
alias kc='kubectx'
alias kn='kubens'
alias fgk='flux get kustomizations'

# Pass
alias pc='pass show -c'

# ~~~~~~~~~~~~~~~ Sourcing ~~~~~~~~~~~~~~~~~~~~~~~~

# Source private configuration if it exists
[[ -f "$HOME/.privaterc" ]] && source "$HOME/.privaterc"

# Source fzf completion if available
if command -v fzf >/dev/null 2>&1; then
    source <(fzf --zsh)
fi

# ~~~~~~~~~~~~~~~ Completion ~~~~~~~~~~~~~~~~~~~~~~~~

fpath+=~/.zfunc

# Homebrew completions
if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
fi

autoload -Uz compinit
compinit -u

zstyle ':completion:*' menu select

# ~~~~~~~~~~~~~~~ Package Managers ~~~~~~~~~~~~~~~~~~~~~~~~

# SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# Nix
[[ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]] && source "$HOME/.nix-profile/etc/profile.d/nix.sh"

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH="/usr/local/opt/libpq/bin:$PATH"
