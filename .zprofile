# ==========================================================
# ~/.zprofile — environment setup for login shells
# ==========================================================

# ~~~~~~~~~~~~~~~ OS Detection ~~~~~~~~~~~~~~~~~~~~~~~~
IS_MACOS=false
IS_LINUX=false

if [[ "$OSTYPE" == darwin* ]]; then
  IS_MACOS=true
elif [[ "$OSTYPE" == linux* ]]; then
  IS_LINUX=true
fi

# ~~~~~~~~~~~~~~~ Homebrew Setup ~~~~~~~~~~~~~~~~~~~~~~~~

# Detect and set correct Homebrew prefix
if $IS_MACOS; then
  if [[ $(uname -m) == "arm64" ]]; then
    export HOMEBREW_PREFIX="/opt/homebrew"   # Apple Silicon
  else
    export HOMEBREW_PREFIX="/usr/local"      # Intel
  fi
elif $IS_LINUX; then
  export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
fi

# Initialize Homebrew environment early
if [[ -x "$HOMEBREW_PREFIX/bin/brew" ]]; then
  eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
fi

# ~~~~~~~~~~~~~~~ XDG Base Directories ~~~~~~~~~~~~~~~~~~~~~~~~
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

# ~~~~
