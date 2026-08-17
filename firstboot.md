# Vamos criar um abiente útil de trabalho

Agora que seu sistema fez _boot_ com sua nova instalação de ArchLinux, precisamos realizar alguns últimos passos antes que possa aproveitá-lo, de fato, como ferramenta de produtividade.

A menos que expressamente dito o contrário, todos os comandos são executados como usuário __root__. Uma conta de usuário humano ainda será criada.

Após o _boot_ você será recpecionado com um _prompt_ de login: o usuário é `root` e a senha é a senha registrada com o comando `passwd` ao final da instalação.

## Atalhos e variáveis de ambiente

Pessoalmente, tem alguns atalhos e variáveis de ambiente que ajudam muito na utilização do Linux Console (a presente interface de linha de comando que você está usando). Usando seu editor de texto, crie `~/.bash_profile`, contendo
```
# ~/.bash_profile

# Se existir, carregue ~/.bashrc
if [ -f ~/.bashrc ]; then
  source ~/.bashrc
fi
```
e também crie `~/.bashrc`, contendo
```
# ~/.bashrc

# Variáveis de ambiente
export EDITOR='/bin/nvim'

# Atalhos (aliases) úteis
alias ls='ls --color=always'
alias ll='ls -hl'
alias la='ls -A'
```

Meu editor de texto é o Neovim (`nvim`), você talvez use o `nano` ou outro. Ajuste de acordo. Os atalhos garantem que o comando `ls` colore os diferentes tipos de arquivos e diretórios. O atalho `ll` retorna uma lista de arquivos e diretórios, com tamanho legível para humanos (ao invés da contagem de blocos, que é o padrão POSIX). O atalho `la` lista todos os arquivos, incluindo itens ocultos (cujo nome começa com `.`).

Para ativar essas mudanças na sessão atual, execute `source ~/.bashrc`. Nos próximos logins, isso já ocorrerá automaticamente.

## Otimização do systemd

Por _default_, o systemd inicia o sistema para uma interface gráfica. Nós ainda nem instalamos um ambiente gráfico e, neste tutorial, o sistema sempre irá fazer _boot_ para o console. Para substituir esse comportamento padrão, execute:
```
# systemctl set-default multi-user.target
# systemctl isolate multi-user.target
```

## Conecte-se à Internet e ajuste o gerenciador de pacotes

Caso esteja usando uma rede cabeada, ela já deve estar operando. Caso esteja utilizando uma rede sem fio, precisamos fazer alguns últimos ajustes para configurar o `iwd`:
```
# mkdir /etc/iwd
```
e crie o arquivo `/etc/iwd/main.conf`, contendo:
```
[General]
EnableNetworkConfiguration=true
Country=BR
```

Agora, vamos iniciar os seriços de autenticação de rede sem fio, DHCP (`iwd.service`) e DNS (`systemd-resolved.service`):
```
# systemctl enable --now iwd.service
# systemctl enable --now systemd-resolved.service
```

Aproveitamos e iniciamos o _firewall_:
```
# ufw enable
# ufw logging off
# ufw status verbose
# systemctl enable --now ufw.service
```

Porque nós copiamos o arquivo de configuração de rede, sua conexção sem fio já deve estar funcionando. Cheque executando:
```
# ping -c 3 google.com
```

Confirmando que a conexão à Internet está funcionando, vamos nos certificar que o relógio do sistema está sincronizado:
```
timedatectl set-ntp true
```

Vamos habilitar a saída colorida do gerenciador de pacotes `pacman` e atualizar seu banco de dados (e, possivelmente, também atualizar algum pacote já instalado):
```
# sed -i 's/^#Color$/Color/' /etc/pacman.conf
# pacman -Suy
```

## Ajustes de permissão administrativa

Execute `visudo` e remova o comentário (`#`) da linha `%wheel ALL=(ALL:ALL) ALL`. Isso permite que usuários do grupo `wheel` possam executar comandos com privilégios elevados (da conta __root__) através do comando `sudo` e a senha de usuário.

## Ajustes pessoais

> [!Note]
> Esta seção contém ajustes específicos para o meu MacBook Pro, devendo ser ignorada.

```
# echo '650' > /sys/class/backlight/intel_backlight/brightness
# echo '64' > /sys/class/leds/smc\:\:kbd_backlight/brightness
# rfkill block bluetooth
```

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

Copie `~/.bash_profile` e `~/.bashrc` para `/home/tormena`. Assim, terá o mesmo ambiente e atalhos quando logar com seu usuário. Execute
```
# exit
```
para encerrar a sua sessão e inicie uma nova, com seu novo usuário e senha. Perceba que seu _prompt_ agora termina em
```
$
```

## Set up a GUI

It’s hard to consider a system useful without a web browser. Even though there are a choice number of good text-based web browsers, there’s such a high dependency on JavaScript that a graphical browser is, de facto, a must. So, here we go:
```
pacman -S xorg-server xorg-xinit xorg-xrandr libxft libxinerama ttf-terminus-nerd

mkdir -p ~/.config/fontconfig
cat << 'EOF' > ~/.config/fontconfig/fonts.conf
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">

<fontconfig>

    <!-- General rendering -->
    <match target="font">
        <edit name="antialias" mode="assign">
            <bool>true</bool>
        </edit>

        <!-- Preserve the font's proportions while still getting
             some pixel-grid alignment. -->
        <edit name="hinting" mode="assign">
            <bool>true</bool>
        </edit>

        <edit name="hintstyle" mode="assign">
            <const>hintslight</const>
        </edit>

        <!-- Use the TrueType instructions rather than forcing
             FreeType's autohinter. -->
        <edit name="autohint" mode="assign">
            <bool>false</bool>
        </edit>

        <!-- Grayscale rather than colored LCD fringes. -->
        <edit name="rgba" mode="assign">
            <const>none</const>
        </edit>
    </match>

</fontconfig>
EOF
```

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

## Install some basic utilities

Now we’ll try and get the system useful for productivity work: coding, LaTeX authoring, e-mail, web browsing, and assorted minor utilities. All just for the TTY.

### Web browser

Having a web browser is great for basic usage:
```
pacman -S firefox firefox-dark-reader
```
