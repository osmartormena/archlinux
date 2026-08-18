#!/bin/sh

set +h

# Versão
VERSION=2026

## Ajustando o prefixo
#sudo chown -R tormena:tormena /usr/local
#chmod -R g+rwx /usr/local

## Instalação
#mkdir /usr/local/texlive

if [ ! -L /usr/local/bin/tlmgr ]; then
	curl -LO https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
	mkdir install-tl
	tar -xf install-tl-unx.tar.gz -C install-tl --strip-component=1
	rm install-tl-unx.tar.gz
	cat << EOF > ./install-tl/texlive.profile
# Perfil personalizado de instalação do TeXLive
selected_scheme scheme-infraonly
TEXDIR /usr/local/texlive/$VERSION
TEXMFCONFIG ~/.texlive/texmf-config
TEXMFHOME ~/texmf
TEXMFLOCAL /usr/local/texlive/texmf-local
TEXMFSYSCONFIG /usr/local/texlive/$VERSION/texmf-config
TEXMFSYSVAR /usr/local/texlive/$VERSION/texmf-var
TEXMFVAR ~/.texlive/texmf-var
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

	./install-tl/install-tl -profile ./install-tl/texlive.profile
	rm -r ./install-tl
fi

# Configurando o TeXLive
mkdir /usr/local/texlive/$VERSION/texmf-config/web2c
cat << EOF > /usr/local/texlive/$VERSION/texmf-config/web2c/fmtutil.cnf
# Modificando /usr/local/texlive/$VERSION/texmf−dist/web2c/fmtutil.cnf
#
# Disabilitando formatos não utilizados
#
## latex-bin:
#! dvilualatex luatex language.dat,language.dat.lua dvilualatex.ini
#! latex pdftex language.dat -translate-file=cp227.tcx *latex.ini
#! lualatex luahbtex language.dat,language.dat.lua lualatex.ini
pdflatex pdftex language.dat -translate-file=cp227.tcx *pdflatex.ini
#
## luahbtex:
#! luahbtex luahbtex language.def,language.dat.lua luatex.ini
#
## luatex:
#! dviluatex luatex language.def,language.dat.lua dviluatex.ini
#! luatex luatex language.def,language.dat.lua luatex.ini
#
## pdftex:
#! etex pdftex language.def -translate-file=cp227.tcx *etex.ini
#! pdfetex pdftex language.def -translate-file=cp227.tcx *pdfetex.ini
pdftex pdftex language.def -translate-file=cp227.tcx *pdfetex.ini
EOF

# Instalando pacotes
if [ ! -L /usr/local/bin/pdftex ]; then
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
fi

# Lista de comandos externos habilitados
cat << EOF >> /usr/local/texlive/$VERSION/texmf.cnf
%
% Acrescenta pdftex, pdflatex, biber e gnuplot à lista
shell_escape_commands = \\
pdftex,pdflatex,\\
gnuplot,\\
bibtex,bibtex8,\\
biber,\\
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
texosquery-jre8
EOF

