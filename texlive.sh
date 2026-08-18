#!/bin/sh

# Versão
VERSION=2026

# Instalação
if test ! -d /opt/texlive; then
	echo "Instalando TeXLive ${TL}…"
	mkdir -p /opt/texlive
	if test ! -d install-tl; then
		$CURL https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
		mkdir install-tl
		$TAR install-tl-unx.tar.gz -C install-tl --strip-component=1
		rm install-tl-unx.tar.gz
	fi
	cat > install-tl/texlive.profile << EOF
# Perfil personalizado de instalação do TeXLive
selected_scheme scheme-infraonly
TEXDIR /opt/texlive/$TL
TEXMFCONFIG $HOME/.texlive/$TL/texmf-config
TEXMFHOME $HOME/.texlive/texmf
TEXMFLOCAL /opt/texlive/texmf-local
TEXMFSYSCONFIG /opt/texlive/$TL/texmf-config
TEXMFSYSVAR /opt/texlive/$TL/texmf-var
TEXMFVAR $HOME/.texlive/$TL/texmf-var
binary_universal-darwin 1
instopt_adjustpath 0
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
EOF

	./install-tl/install-tl -no-verify-downloads -profile install-tl/texlive.profile
	rm -r install-tl
	echo "Desabilitando formatos não utilizados…"
	mkdir -p /opt/texlive/$TL/texmf-config/web2c
	cat > /opt/texlive/$TL/texmf-config/web2c/fmtutil.cnf << EOF
# Modificando /opt/texlive/$TL/texmf−dist/web2c/fmtutil.cnf
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

	echo "Instalando pacotes adicionais…"
	echo "Da collection-basic:"
	echo "Da collection-latex:"
	echo "Da collection-latexrecommended:"
	echo "Da collection-latexextra:"
	echo "Da collection-fontsrecommended:"
	echo "Da collection-binextra:"
	echo "Da collection-bibtexextra:"
	echo "Da collection-mathscience:"
	echo "Da collection-pictures:"
	echo "Da collection-langenglish:"
	echo "Da collection-langeuropean:"
	echo "Da collection-langfrench:"
	echo "Da collection-langgerman:"
	echo "Da collection-langitalian:"
	echo "Da collection-langportuguese:"
	echo "Da collection-langspanish:"
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
	echo "TeXLive $TL instalado."
else echo "TeXLive $TL já instalado.";
fi

#	Habilita alguns comandos externos extras
cat >> /opt/texlive/$TL/texmf.cnf << EOF
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

#	Remove código ARM64 dos binários universais
find /opt/texlive/$TL/bin/universal-darwin -type f | while read bin; do
	arch=`lipo -archs $bin`
	if echo "$arch" | grep -q "arm64"; then
		lipo -remove arm64 $bin -output $bin
	fi
done
