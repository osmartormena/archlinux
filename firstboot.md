# Set up an useful environment

All commands are run as `root` within the fresh installed system. After the boot process, login as _root_ and type the _password_ defined in the last section.

First, let’s get adjust the profile and rc files:
```
cat << EOF > ~/.bash_profile
# /root/.bash_profile

# If it exists, load /root/.bashrc
if [ -f /root/.bashrc ]; then
  source /root/.bashrc
fi
EOF

cat << EOF > ~/.bashrc
# /root/.bashrc

# Some useful environment variables
export EDITOR='/bin/nvim'

# Some useful aliases
alias ls='ls --color=always'
alias ll='ls -hl'
alias la='ls -A'
EOF
```

To activate the aliases, run `source ~/.bashrc`.

## Some systemd setup

By default, systemd runs with a _graphical.target_. Let’s switch it to the _multi-user.target_, so _display-manager.service_ doesn’t get enabled.
```
systemctl set-default multi-user.target
systemctl isolate multi-user.target
```

## Connect to the internet and set up pacman

First, let’s configure `iwd`:
```
mkdir /etc/iwd
cat << EOF > /etc/iwd/main.conf
[General]
EnableNetworkConfiguration=true
Country=BR
EOF
```

Now, let’s start the services:
```
systemctl enable --now iwd.service
systemctl enable --now systemd-resolved.service
```

Because we copied the authentication file from the live iso, the WiFi should be working already.

It is advisable to update the pacman database (and possibly upgrade some freshly installed package). Also, we'll enable colored output for pacman.
```
sed -i 's/^#Color$/Color/' /etc/pacman.conf
pacman -Suy
```

## Some more systemd setup
Now that wireless networking should work reliably, let’s setup some more units:
```
timedatectl set-ntp true
echo '650' > /sys/class/backlight/intel_backlight/brightness
echo '64' > /sys/class/leds/smc\:\:kbd_backlight/brightness
rfkill block bluetooth
```

## Ativando o firewall
```
ufw enable
ufw logging off
ufw status verbose
systemctl enable --now ufw.service
```

## Set up a human user account

We’ll use *systemd-homed* to create an encrypted volume under `/home`.
```
systemctl enable --now systemd-homed.service
```

Modify `/etc/systemd/homed.conf`, so that it contains:
```
[Home]
DefaultStorage=luks
DefaultFileSystemType=btrfs
```

Now we run:
```
homectl create tormena \
--real-name="Osmar Tormena Júnior" \
--email-address=tormena@utfpr.edu.br \
--location="Campo Mourão, PR, BR" \
--birth-date=1986-03-06 \
--member-of=wheel \
--luks-extra-mount-options="compress=zstd:3,noatime"
homectl activate tormena
homectl inspect tormena
```

### Make this user a sudoer

Checking that the user belongs to group _wheel_:
```
id tormena
```

Run `visudo` and uncomment the line `%wheel ALL=(ALL:ALL) ALL`. Save an quit.

Copy `.bash_profile` and `.bashrc` from the `/root` directory to `/home/tormena`, adjusting it.

## Install basic development utilities
```
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
