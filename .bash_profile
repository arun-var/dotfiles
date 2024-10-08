# Only run on macOS

if [[ "$OSTYPE" == "darwin"* ]]; then
  # needed for brew
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Only run these on Ubuntu and Fedora

#if [[ $(grep -E "^(ID|NAME)=" /etc/os-release | grep -Eq "ubuntu|fedora")$? == 0 ]]; then
# needed for brew to work
#	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
#fi

if [ -r ~/.bashrc ]; then
  source ~/.bashrc
fi

export XDG_CONFIG_HOME="$HOME"/.config

if [ -e /home/arun/.nix-profile/etc/profile.d/nix.sh ]; then . /home/arun/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
