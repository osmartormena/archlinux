#!/bin/sh
# User (not root) programs installation and setup.

# Change ownership of /usr/local
sudo chown -R tormena /usr/local
sudo chgrp -R tormena /usr/local
mkdir /usr/local/texlive
mkdir /usr/local/MATLAB

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

cat << EOF > install-tl/texlive.profile
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

mkdir /usr/local/texlive/2026/texmf-config/web2c
cat << EOF > /usr/local/texlive/2026/texmf-config/web2c/fmtutil.cnf
# Substituting /usr/local/texlive/2026/texmf−dist/web2c/fmtutil.cnf
#
# Disabling unused formats
#
# from latex-bin:
#! dvilualatex luatex language.dat,language.dat.lua dvilualatex.ini
#! latex pdftex language.dat -translate-file=cp227.tcx *latex.ini
#! lualatex luahbtex language.dat,language.dat.lua lualatex.ini
pdflatex pdftex language.dat -translate-file=cp227.tcx *pdflatex.ini
#
# from luahbtex:
#! luahbtex luahbtex language.def,language.dat.lua luatex.ini
#
# from luatex:
#! dviluatex luatex language.def,language.dat.lua dviluatex.ini
#! luatex luatex language.def,language.dat.lua luatex.ini
#
# from pdftex:
#! etex pdftex language.def -translate-file=cp227.tcx *etex.ini
#! pdfetex pdftex language.def -translate-file=cp227.tcx *pdfetex.ini
pdftex pdftex language.def -translate-file=cp227.tcx *pdfetex.ini
EOF

tlmgr install \
		amsfonts bibtex cm colorprofiles etex graphics-def hyphenex ifplatform iftex knuth-lib pdftex plain tex-ini-files texlive-common texlive-en texlive-msg-translations tlshell unicode-data \
		amsmath babel babel-english babelbib carlisle epstopdf-pkg etoolbox fancyhdr firstaid fix2col geometry graphics hyperref l3backend l3kernel l3packages latex latex-bin latex-fonts natbib oberdiek tools url \
		booktabs cmap everyshi listings mathtools memoir microtype pdflscape pdfpages textcase xcolor xfrac \
		acro cancel csquotes listingsutf8 multirow pdfx standalone translations xmpincl xpatch \
		lm \
		latexmk synctex texdoc\
		biber biblatex biblatex-abnt \
		chemformula physconst siunitx \
		circuitikz pgf pgfplots \
		babel-latin babel-french babel-german babel-italian babel-portuges babel-spanish \
		hyphen-english hyphen-latin hyphen-french hyphen-german hyphen-italian hyphen-portuguese hyphen-spanish \
		tabularray-abnt

cat << EOF >> /usr/local/texlive/2026/texmf.cnf
%
% Add pdftex, pdflatex, biber, and gnuplot to the list
shell_escape_commands = \\
pdftex,pdflatex,\\
gnuplot,\\
bibtex,bibtex8,\\
extractbb,\\
gregorio,\\
kpsewhich,\\
l3sys-query,\\
latexminted,\\
makeindex,\\
memoize-extract.pl,\\
memoize-extract.py,\\
repstopdf,\\
r-mpost,\\
texosquery-jre8,\\
EOF
