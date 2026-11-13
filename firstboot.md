## Criando uma conta de usuário (humano)

Nós vamos usar o `systemd-homed` para criar um volume encriptado sob `/home`. Ao meu ver, essa abordagem possui vantagens sobre a encriptação total de disco. Desta forma, apenas os arquivos pessoais são encriptados e o desbloqueio do volume ocorre no ato de login, ao invés do _boot_.

Primeiro, precisamos habilitar o serviço:
```
# systemctl enable --now systemd-homed.service
```

Edite o arquivo `/etc/systemd/homed.conf`, de forma que contenha:
```
[Home]
DefaultStorage=luks
DefaultFileSystemType=btrfs
```

Agora, execute (mudando as informações, nome de usuário e tamanho do volume, conforme apropriado):
```
# homectl create tormena \
> --real-name="Osmar Tormena Júnior" \
> --email-address=tormena@utfpr.edu.br \
> --location="Campo Mourão, PR, BR" \
> --birth-date=1986-03-06 \
> --member-of=wheel \
> --disk-size=10G \
> --luks-extra-mount-options="compress=zstd:3,noatime"
# homectl activate tormena
# homectl inspect tormena
```
Não se preocupe demais com o tamanho do volume (usei aqui 10 GB). Ele pode ser expandido ou encolhido conforme necessário. Apenas garanta espaço de sobra em sua partição BTRFS, ou terá problemas!

Checando que a nova conta de usuário pertence ao grupo `wheel`:
```
# id tormena
```

Copie `~/.bash_profile` e `~/.bashrc` para `/home/tormena`.
```
# cp /root/.bash_profile /home/tormena/
# cp /root/.bashrc /home/tormena/
```
Assim, terá o mesmo ambiente e atalhos quando logar com seu usuário.

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
