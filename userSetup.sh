#!/bin/sh
# User (not root) programs installation and setup.

# Webcam (requires sudo)
cd ~/Projects
git clone https://aur.archlinux.org/facetimehd-firmware.git
cd facetimehd-firmware
makepkg -si
cd ..
git clone https://aur.archlinux.org/facetimehd-dkms-git.git
cd facetimehd-dkms-git
makepkg -si
cd
sudo modprobe facetimehd

# If the camera fails to initialize after a major kernel upgrade, rebuild your DKMS modules using `sudo dkms autoinstall` or reinstall the `facetimehd-dkms-git` package.

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

# GnuPG setup
export GPG_TTY=$(tty)
EOF

# Setup neovim
mkdir ~/.config/nvim
cat << EOF > ~/.config/nvim/init.lua
-- Opções de edição
vim.opt.fileencodings	= "utf-8"	-- apenas para arquivos já existentes
vim.opt.history				= 10			-- mantenha pequeno histórico
vim.opt.ignorecase		= true		-- ignore capitalização na busca
vim.opt.linebreak			= true		-- apenas querbe a linha em alguns caracteres
vim.opt.number				= true		-- mostre os números de linha
vim.opt.ruler					= true		-- mostre a linha e coluna sob o cursor
vim.opt.shada					= ""			-- não guarde histórico de sessão
vim.opt.shiftwidth		= 2				-- espaço de identação
vim.opt.showcmd				= true		-- sugestão de completar comandos
vim.opt.smartcase			= true		-- se a busca for maiúscula, torne-a sensível à capitalização
vim.opt.tabstop				= 2				-- espaços do tab

-- Limpeza do healthcheck()
vim.g.loaded_python3_provider	= 0	-- desabilita suporte ao Python 3
vim.g.loaded_ruby_provider		= 0	-- desabilita suporte ao Ruby
vim.g.loaded_perl_provider		= 0	-- desabilita suporte ao Perl
vim.g.loaded_node_provider		= 0	-- desabilita suporte ao Node.js

-- Plugins (vim.pack)
vim.pack.add({
	'https://github.com/lervag/vimtex'	--	VimTeX
})
EOF

nvim --headless -c "lua vim.pack.update(nil, { force = true })" -c "qa"
nvim --headless -c "helptags ALL" -c "q"

mkdir ~/.config/nvim/ftplugin
cat << EOF > ~/.config/nvim/ftplugin/tex.vim
" reconheça arquivos \".tex\" como LaTeX
let g:tex_flavor = 'latex'

" ajuste de identação
setlocal softtabstop=2

" Não abra o menu QuickFix para avisos sem erros
let g:vimtex_quickfix_open_on_warning = 0

" Use o Skim como o visualizados de PDF do vimtex
let g:vimtex_view_method = 'zathura'
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
tlmgr path add
texhash

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

# Set up MATLAB
sudo pacman -S debootstrap debian-archive-keyring xorg-xhost
sudo mkdir -p /opt/matlab-r2026a
sudo debootstrap \
    --arch=amd64 \
    --variant=minbase \
    trixie \
    /opt/matlab-r2026a \
    http://deb.debian.org/debian
sudo tee /opt/matlab-r2026a/etc/apt/sources.list >/dev/null <<'EOF'
deb http://deb.debian.org/debian trixie main contrib non-free non-free-firmware
deb http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
EOF

sudo mkdir -p /opt/matlab-r2026a/home/tormena
sudo mkdir -p /opt/matlab-r2026a/tmp/.X11-unix

sudo mount --rbind /run /opt/matlab-r2026a/run
sudo mount --make-rslave /opt/matlab-r2026a/run

sudo mount --rbind /dev /opt/matlab-r2026a/dev
sudo mount --make-rslave /opt/matlab-r2026a/dev

sudo mount --rbind /proc /opt/matlab-r2026a/proc
sudo mount --make-rslave /opt/matlab-r2026a/proc

sudo mount --rbind /sys /opt/matlab-r2026a/sys
sudo mount --make-rslave /opt/matlab-r2026a/sys

sudo mount --rbind /run /opt/matlab-r2026a/run
sudo mount --make-rslave /opt/matlab-r2026a/run

sudo mount --bind /tmp/.X11-unix \
    /opt/matlab-r2026a/tmp/.X11-unix

sudo mount --bind /home/tormena \
    /opt/matlab-r2026a/home/tormena

sudo chroot /opt/matlab-r2026a /bin/bash
# inside the chroot
apt install \
    ca-certificates \
    curl \
    wget \
    unzip \
    xz-utils \
    file \
    sudo \
    locales \
    procps \
    psmisc \
    dbus \
    dbus-x11

export PATH=$PATH:/sbin
groupadd -g 1000 tormena
useradd \
    -u 1000 \
    -g 1000 \
    -d /home/tormena \
    -s /bin/bash \
    tormena
chown 1000:1000 /home/tormena

apt install \
    libx11-6 \
    libx11-xcb1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrender1 \
    libxrandr2 \
    libxinerama1 \
    libxcursor1 \
    libxdamage1 \
    libxcomposite1 \
    libxss1 \
    libxt6 \
    libxmu6 \
    libxkbcommon0 \
    libxkbcommon-x11-0 \
    libxcb1 \
    libxcb-glx0 \
    libxcb-render0 \
    libxcb-shm0 \
    libxcb-randr0 \
    libxcb-xinerama0 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-util1 \
    libglib2.0-0 \
    libfontconfig1 \
    libfreetype6 \
    libnss3 \
    libasound2 \
    libgtk-3-0 \
    libgbm1 \
    libdrm2 \
    libgl1 \
    libegl1 \
    libglu1-mesa \
    mesa-utils \
    mesa-vulkan-drivers
exit
# back to host
sudo chroot /opt/matlab-r2026a apt install x11-utils
sudo mkdir -p /opt/matlab-r2026a/usr/local/MATLAB
sudo chown -R 1000:1000 /opt/matlab-r2026a/usr/local/MATLAB
wget https://www.mathworks.com/mpm/glnxa64/mpm
chmod +x mpm
sudo mv mpm /opt/matlab-r2026a/usr/local/bin
sudo chroot \
    --userspec=1000:1000 \
    /opt/matlab-r2026a \
    /usr/bin/env \
        HOME=/home/tormena \
        USER=tormena \
        LOGNAME=tormena \
        SHELL=/bin/bash \
        /bin/bash --login
# back to chroot (not as root, though)
mpm install \
    --release=R2026a \
    --destination=/usr/local/MATLAB/R2026a \
    --products=MATLAB
/usr/local/MATLAB/R2026a/bin/matlab
# it works!

# Matlab launcher from arch
# umount all the binds used here
# Add the following to /ect/fstab
# MATLAB R2026a Debian 13 chroot

/dev                    /opt/matlab-r2026a/dev             none    bind    0 0
/dev/pts                /opt/matlab-r2026a/dev/pts         none    bind    0 0
/dev/shm                /opt/matlab-r2026a/dev/shm         none    bind    0 0
/dev/mqueue             /opt/matlab-r2026a/dev/mqueue      none    bind    0 0

/proc                   /opt/matlab-r2026a/proc            none    bind    0 0
/sys                    /opt/matlab-r2026a/sys             none    bind    0 0
/run                    /opt/matlab-r2026a/run             none    bind    0 0

/home/tormena           /opt/matlab-r2026a/home/tormena    none    bind    0 0

/tmp/.X11-unix          /opt/matlab-r2026a/tmp/.X11-unix   none    bind    0 0



cat << EOF > /usr/local/bin/matlab
#!/bin/sh

exec /usr/local/matlab/bin/matlab
EOF

chmod +x /usr/local/bin/matlab
