#!/bin/sh
#

# Populate de $HOME directory, set bash_profile and bashrc
LC_ALL=C xdg-user-dirs-update
cat << EOF > ~/.bash_profile
# Source ~/.bashrc if it exists
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi
fastfetch
EOF

cat << EOF > ~/.bashrc
# Usefull aliases
alias ls='ls --color=always --human-readable'
alias ll='ls -l'
alias la='ls -A'
alias vim='nvim'
alias ff='fastfetch'
EOF

# Get the suckless tools
mkdir Projects/suckless
cd Projects/suckless
git clone https://git.suckless.org/dwm
git clone https://git.suckless.org/dmenu
git clone https://git.suckless.org/slstatus
cd
