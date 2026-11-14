## Instalar uma interface gráfica

Para que o teclado com acentos também funcione na GUI
```
localectl --no-convert set-x11-keymap us "" intl
localectl
```

### Suckless

```
Terminess Nerd Font Mono:size=10
```

### X11-Xorg
On the human user account, create the files
```
cat << EOF > ~/.xinitrc
#!/bin/sh

xrdb -merge ~/.Xresources

slstatus &
exec dwm
EOF

chmod +x ~/.xinitrc

cat << EOF > ~/.Xresources
Xft.dpi: 227
Xft.antialias: 1
Xft.hinting: 1
Xft.hintstyle: hintslight
Xft.autohint: 0
Xft.rgba: none
EOF
```

Agora, basta executar `startx` para abrir a GUI.
