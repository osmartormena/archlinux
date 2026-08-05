#!/bin/sh
#

# Change ownership of /usr/local
sudo chown -R tormena /usr/local
sudo chgrp -R tormena /usr/local
mkdir /usr/local/texlive

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
mkdir ~/Projects/suckless
cd ~/Projects/suckless
git clone https://git.suckless.org/dwm
git clone https://git.suckless.org/dmenu
git clone https://git.suckless.org/slstatus
cd

# Set up allacritty
mkdir ./config/alacritty
cat << EOF > ~/.config/alacritty/alacritty.toml
[font]
size = 12.0

[font.bold]
family = "Terminess Nerd Font Mono"
style = "Bold"

[font.bold_italic]
family = "Terminess Nerd Font Mono"
style = "Bold Italic"

[font.italic]
family = "Terminess Nerd Font Mono"
style = "Italic"

[font.normal]
family = "Terminess Nerd Font Mono"
style = "Regular"
EOF

# Set up Xorg
cat << EOF > ~/.Xresources
Xft.dpi: 227
EOF

cat << EOF > ~/.xinitrc
#!/bin/sh

xrdb -merge ~/.Xresources

slstatus &
exec dwm
EOF

chmod +x ~/.xinitrc

# Set up TeX Live
curl -LO https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
mkdir install-tl
tar -xf install-tl-unx.tar.gz -C install-tl --strip-component=1
rm install-tl-unx.tar.gz

cat > install-tl/texlive.profile << EOF
# Custom installation profile.
selected_scheme scheme-infraonly
TEXDIR /usr/local/texlive/2026
TEXMFCONFIG ~/.texlive2026/texmf-config
TEXMFHOME ~/texmf
TEXMFLOCAL /usr/local/texlive/texmf-local
TEXMFSYSCONFIG /usr/local/texlive/2026/texmf-config
TEXMFSYSVAR /usr/local/texlive/2026/texmf-var
TEXMFVAR ~/.texlive2026/texmf-var
binary_x86_64-linux 1
instopt_adjustpath 1
instopt_adjustrepo 1
instopt_letter 0
instopt_portable 0
instopt_write18_restricted 1
tlpdbopt_autobackup 0
tlpdbopt_backupdir tlpkg/backups
tlpdbopt_create_formats 1
tlpdbopt_desktop_integration 0
tlpdbopt_file_assocs 0
tlpdbopt_generate_updmap 1
tlpdbopt_install_docfiles 1
tlpdbopt_install_srcfiles 0
tlpdbopt_post_code 1
tlpdbopt_sys_bin /usr/local/bin
tlpdbopt_sys_info /usr/local/info
tlpdbopt_sys_man /usr/local/man
EOF

./install-tl/install-tl -profile install-tl/texlive.profile
rm -r install-tl
