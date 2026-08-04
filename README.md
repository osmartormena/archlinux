# archlinux-macbookpro12.1
My personal step-by-step installation of ArchLinux on my early 2015 MBP.

## Boot archlinux 2026-08-01 live ISO image
Set up keyboard layout and console font:
```
loadkeys us-acentos
setfont ter-132b
```

Connect to a wireless network via `iwctl`.

Ensure time synchronization is set:

`timedatectl`

## archinstall
Run `archinstall` (version 4.4):
1. Do not change archinstall language — it messes the font in HiDPI;
2. Locales > set keyboard layout to `us-acentos`; set console font to `ter-132b`;
3. Do not constrain your mirrors to your country only;
4. Disk configuration > Partitioning > Use best effort default > btrfs > use subvolumes > use compression; no LVM; no disk encryption (yet); Btrfs snapshots > Snapper;
5. Swap on zram, with zstd compression;
6. Bootloader > systemd-boot; UKI enabled; Plymouth (yes);
7. Kernel > Linux;
8. Hostname > archlinux;
9. Authentication > root password; do not set an user account yet;
10. Profile > Xorg; graphics driver > Intel (open source);
11. Applications > enable Bluetooth; `pipewire` audio; enable print service; enable `power-profiles-daemon`; set firewall to `uwd`; no additional fonts;
12. Network configuration > standalone iwd;
13. Colored pacman output;
14. Additional packages > `btrfs-progs` and `dosfstools` (filesystems tools for this installation); `systemd-resolvconf` (for DNS); `wireless-regdb` (for WiFi reliability); `neovim` (text editor); `man-db`, `man-pages`, and `texinfo` (documentation); `terminus-font` and `ttf-terminus-nerd` (system fonts); `bash-completion` (convenience);
15. Set your time zone;
16. Enable NTP;

Install.

## First boot
Let’s finish the configuration using the root account.

### Network and firewall configuration
Run `iwctl` to authenticate with your wireless network.
```
systemctl start ufw
systemctl enable ufw
```

### Set some aliases
```
cat << EOF > ~/.bash_profile
# Source ~/.bashrc if it exists
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi
EOF

cat << EOF > ~/.bashrc
# Useful aliases
alias ls='ls --color=always'
alias ll='ls -l'
alias la='ls -A'
```

### Update pacman
`pacman -Suy`

### systemd configuration
```
sed -i 's/^timeout 3$/timeout 0/' /boot/loader/loader.conf
sed -i 's/relatime/noatime/g' /etc/fstab
systemctl set-default multi-user.target
echo 694 > /sys/class/backlight/intel_backlight/brightness
echo 128 > /sys/class/leds/smc\:\:kbd_backlight/brightness
```

### Create a snapshot
Now that the system is properly configured, up, and running, let’s create a snapshot for the root partition, before we go along with more packages and configurations.
```
```

## Set up an user account
A
