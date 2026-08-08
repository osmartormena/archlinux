# archlinux-macbookpro12.1
My personal step-by-step installation of ArchLinux on my early 2015 MBP.

## Boot archlinux 2026-08-01 live ISO image
Set up keyboard layout and console font:
```
loadkeys br-latin1-us
setfont ter-132b
```

Connect to a wireless network via `iwctl`.

Ensure time synchronization is set:

`timedatectl`

## archinstall
Run `archinstall` (version 4.4):
1. Do not change archinstall language — it messes the font in HiDPI;
2. Locales > set keyboard layout to `br-latin1-us`; set console font to `ter-132b`;
3. Do not constrain your mirrors to your country only;
4. Disk configuration > Partitioning > Use best effort default > ext4 > no /home partition; no LVM; no disk encryption;
5. Swap on zram, with zstd compression;
6. Bootloader > systemd-boot; UKI enabled; Plymouth (yes);
7. Kernel > Linux;
8. Hostname > archlinux;
9. Authentication > root password; set regular user (sudoer);
10. Profile > Xorg; graphics driver > Intel (open source);
11. Applications > enable Bluetooth; `pipewire` audio; enable print service; enable `power-profiles-daemon`; set firewall to `uwd`; no additional fonts (maybe check a firefox dependency, noto);
12. Network configuration > standalone iwd;
13. Colored pacman output;
14. Additional packages > `e2fsprogs` and `dosfstools` (filesystems tools for this installation); `systemd-resolvconf` (for DNS); `wireless-regdb` (for WiFi reliability); `neovim`, `ripgrep`, and `xclip` (text editor, and dependencies); `man-db`, `man-pages`, and `texinfo` (documentation); `terminus-font` and `ttf-terminus-nerd` (system fonts); `bash-completion` and `xdg-user-dirs` (convenience); `base-devel`, `gcc-fortran`, `git`, `github-cli`, `linux-headers`, and `openssh` (developing tools); `fastfetch` and `htop` (eye-candy); `alacritty` and `firefox` (GUI apps); `gnuplot` and `zathura-pdf-mupdf` (for TeXLive);
15. Set your time zone;
16. Enable NTP;

Install.

## First boot
Let’s finish the configuration using the root account.

### Network setup
Run `iwctl` to authenticate your wireless network.

### Bootstrap the system
Run `bootstrap.sh`.

## Regular user
Run `userSetup.sh`. Compile the suckless tools according to the instructions. Set the font on `.../dwm/config.h` to `"Terminess Nerd Font Mono:size=10:antialias=false:autohint=false"`.

`startx` should work now.

Open `firefox`. It should look HUGE! Type `about:config` in the address bar, search for `layout.css.devPixelsPerPx` and set it to `0.75`.
