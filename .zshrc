# ~~~~~~~~~~~~~~~ Environment Variables ~~~~~~~~~~~~~~~~~~~~~~~~

# Editor
set -o vi
export VISUAL="nvim"
export EDITOR="nvim"

# OS detection
IS_MACOS=false
IS_LINUX=false
if [[ "$OSTYPE" == darwin* ]]; then
  IS_MACOS=true
elif [[ "$OSTYPE" == linux* ]]; then
  IS_LINUX=true
fi

# Terminal and Browser
if $IS_MACOS; then
  export TERM="xterm-256color"
  export BROWSER="open"
else
  export TERM="tmux-256color"
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
export GOPATH="$HOME/go"

# ~~~~~~~~~~~~~~~ Path Configuration ~~~~~~~~~~~~~~~~~~~~~~~~

setopt extended_glob null_glob

# Detect correct Homebrew prefix
if $IS_MACOS; then
  if [[ $(uname -m) == "arm64" ]]; then
    export HOMEBREW_PREFIX="/opt/homebrew"
  else
    export HOMEBREW_PREFIX="/usr/local"
  fi
elif $IS_LINUX; then
  export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
fi

# Add OS-specific paths
EXTRA_PATHS=()

if $IS_MACOS; then
  EXTRA_PATHS+=(
    "$HOMEBREW_PREFIX/bin"
    /usr/local/MacGPG2/bin
    "$HOME/.asdf/shims"
    "$HOME/.local/bin/aws-cli"
    /System/Cryptexes/App/usr/bin
    /usr/sbin
    /sbin
  )
elif $IS_LINUX; then
  EXTRA_PATHS+=(
    "$HOMEBREW_PREFIX/bin"
    "$HOME/.asdf/shims"
    /opt/nvim-linux64/bin
    /usr/local/opt/libpq/bin
  )
fi

# Final PATH assembly
path=(
  $HOME/bin
  $HOME/.local/bin
  $SCRIPTS
  $HOME/.rd/bin                   # Rancher Desktop
  /bin
  /usr/bin
  /sbin
  $EXTRA_PATHS
  $path
)

# Clean up duplicates and non-existent directories
typeset -U path
path=($^path(N-/))
export PATH

# ~~~~~~~~~~~~~~~ SSH / GPG ~~~~~~~~~~~~~~~~~~~~~~~~

# Only enable outside containers
if [[ -z "$REMOTE_CONTAINERS" && -z "$CODESPACES" && -z "$DEVCONTAINER_TYPE" ]]; then
  export GPG_TTY="$(tty)"
  unset SSH_AGENT_PID
  if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
  fi
  gpgconf --launch gpg-agent
  gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1
fi

# ~~~~~~~~~~~~~~~ Homebrew Integration ~~~~~~~~~~~~~~~~~~~~~~~~

if [[ -x "$HOMEBREW_PREFIX/bin/brew" ]]; then
  eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
fi

# ~~~~~~~~~~~~~~~ direnv Integration ~~~~~~~~~~~~~~~~~~~~~~~~

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# ~~~~~~~~~~~~~~~ History ~~~~~~~~~~~~~~~~~~~~~~~~

HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_IGNORE_SPACE HIST_IGNORE_DUPS SHARE_HISTORY

# ~~~~~~~~~~~~~~~ Prompt (pure) ~~~~~~~~~~~~~~~~~~~~~~~~

PURE_GIT_PULL=0
fpath+=("$HOME/.zsh/pure")
autoload -U promptinit; promptinit
prompt pure

# ~~~~~~~~~~~~~~~ Aliases ~~~~~~~~~~~~~~~~~~~~~~~~

alias v="nvim"
alias vim="nvim"
alias c="clear"
alias e="exit"
alias t="tmux"
alias icloud="cd $ICLOUD"

# Repos
alias dot="cd $GHREPOS/dotfiles"
alias repos="cd $REPOS"
alias ghrepos="cd $GHREPOS"
alias gr="ghrepos"
alias cdgo="cd $GHREPOS/go"

# Navigation
alias scripts="cd $SCRIPTS"
alias cdblog="cd ~/websites/blog"

# ls commands
if $IS_MACOS; then
  alias ls="ls -G"
else
  alias ls="ls --color=auto"
fi
alias la="ls -lathr"
alias lastmod='find . -type f -not -path "*/\.*" -exec ls -lrt {} +'

# Package manager aliases
if $IS_MACOS; then
  alias update="brew update && brew upgrade"
else
  alias syu="sudo pacman -Syu"
fi

# Git / GitHub
alias gp="git pull"
alias gs="git status"
alias lg="lazygit"

# Azure
alias sub="az account set -s"

# Kubernetes
alias k="kubectl"
alias kgp="kubectl get pods"
alias kc="kubectx"
alias kn="kubens"
alias fgk="flux get kustomizations"

# Password store
alias pc="pass show -c"

# ~~~~~~~~~~~~~~~ Sourcing ~~~~~~~~~~~~~~~~~~~~~~~~

[[ -f "$HOME/.privaterc" ]] && source "$HOME/.privaterc"

# fzf completion
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

# ~~~~~~~~~~~~~~~ Completion ~~~~~~~~~~~~~~~~~~~~~~~~

fpath+=("$HOME/.zfunc")
if type brew &>/dev/null; then
  FPATH="$($HOMEBREW_PREFIX/bin/brew --prefix)/share/zsh-completions:$FPATH"
fi

autoload -Uz compinit
compinit -u
zstyle ':completion:*' menu select

# ~~~~~~~~~~~~~~~ Package Managers ~~~~~~~~~~~~~~~~~~~~~~~~

# SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# Nix
[[ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]] && source "$HOME/.nix-profile/etc/profile.d/nix.sh"

# NVM
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
