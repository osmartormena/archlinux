# Installing ArchLinux from a bootable thumbdrive

All commands are run as `root` within the live environment.

## Setting keyboard mapping, console font, and system locale

The man page for *loadkeys* says that the keymaps are stored in `/usr/share/kbd/keymaps`, which is owned by the _kbd_ package, which itself is a dependency of _systemd_, which is a dependency of the _base_ package. So, nothing to be done here.

The *setfont* man page says that the console fonts are in `/usr/share/kbd/consolefonts`, which is owned by _kbd_ and _terminus-font_ packages. The font I’ve chosen is from _terminus-font_, so I’ll push this dependency into the package stack.
```
loadkeys br-latin1-us
setfont ter-132b
```
These choices allow me to input accented characters and works well with my keyboard.

## Connect to the internet

First, to unlock access to 5 GHz (and 6 GHz) bands for WiFi, the _wireless-regdb_ package is necessary (pushed to package stack). Running
```
iw reg set BR
```
allows me to properly use my WiFi card with faster wireless networks.

Now, running *iwctl* gets me authenticated to a WPA-PSK wireless network. So _iwd_ is also pushed to the package stack.
```
iwctl --passphrase=PASSPHRASE station DEVICE connect SSID
```
Substituting _PASSPHRASE_, _DEVICE_, and _SSID_ accordingly. If you need to connect to WPA Enterprise network, refer to `man iwd.network`. In the installed system, _iwd_ can provide a DHCP client, but requires configuration, refer to `man iwd.config`.

Now, we can test the network connectivity:
```
ping -c 3 ping.archlinux.org
```

## Update the system clock

It is recommended to ensure the system clock is synchronized to prevent package signature failures. Just run:
```
timedatectl
```
which is part of _systemd_.

## NVRAM EFI boot entries (optional)

If you have installed (and reinstalled) distros, multiple times, trying to get it right, your NVRAM may have a lot of stale entries. Because Apple UEFI implementation don't show us the available space, it is reasonable to check if it's not too full.

Running `efibootmgr` gives me the following output:
```
BootCurrent: 0000
Timeout: 5 seconds
BootOrder: 0000,0001,0080
Boot0000* Linux Boot Manager	…
Boot0001* Fallback Linux Boot Manager	…
Boot0080* Mac OS X	…
Boot0081* Mac OS X	…
BootFFFF* 	…
```

I have 5 entries: `0000` and `0001` are archlinux (the last one, a fallback); `0080`, `0081`, and `FFFF` are from Apple and I prefer not to touch them. If you have other entries, they may be removed by running `efibootmgr -b ???? -B`, where `????` is the 4-digit entry number.

To keep my NVRAM from bloating (and prevent future installation errors), I'll run:
```
efibootmgr -b 0000 -B
efibootmgr -b 0001 -B
```
Now, we also push _efibootmgr_ to the package stack.

## Partition the disk, create and mount the filesystems

I'll create an EFI System Partition (1 GB) and a Linux root partition, using `systemd-repart` (part of _systemd_).

Let's create the partition definition files:
```
mkdir /tmp/repart.d

cat << EOF > /tmp/repart.d/00-esp.conf
[Partition]
Type=esp
Label=EFI
SizeMinBytes=1G
SizeMaxBytes=1G
Format=vfat
MountPoint=/boot:defaults,noatime
EOF

cat << EOF > /tmp/repart.d/01-root.conf
[Partition]
Type=root
Label=Arch Linux
Format=btrfs
MakeDirectories=/@ /@home
Subvolumes=/@ /@home
DefaultSubvolume=/@
MountPoint=/@:defaults,noatime
MountPoint=/@home:defaults,noatime
Compression=zstd
EOF
```

Before commiting to disk, check the partition layout with:
```
systemd-repart --dry-run=yes --empty=force --definitions=/tmp/repart.d --offline=yes --append-fstab=replace --generate-fstab=/tmp/fstab /dev/sda
```

If everything checks out, then run:
```
systemd-repart --dry-run=no --empty=force --definitions=/tmp/repart.d --offline=yes --append-fstab=replace --generate-fstab=/tmp/fstab /dev/sda
```

Because we used a FAT32 and a BTRFS filesystems, we need to push _dosfstools_ and _btrfs_progs_ to our packages stack.

### Mount for Arch installation

Now, let's mount the filesystems for the installation
```
mount -o subvol=@,noatime,compress=zstd /dev/sda2 /mnt

mkdir /mnt/home
mount -o subvol=@home,noatime,compress=zstd /dev/sda2 /mnt/home

mkdir /mnt/boot
mount -o noatime /dev/sda1 /mnt/boot
```

Quick check the partition and subvolumes:
```
lsblk -f /dev/sda
findmnt
blkid /dev/sda1 /dev/sda2
cat /tmp/fstab
btrfs subvolume list /mnt -t
```

## Installing the (bare-bones) system

Now it’s time to pop our package stack. We obviously need a kernel (`linux`), some firmware (`linux-firmware`), and the base system (`base`). But, we also absolutelly need `iwd` and `wireless-regdb` for wireless networking. We should also install: CPU microcode (`intel-ucode`); filesystem utilities (`efibootmgr`, `dosfstools`, and `btrfs-progs`); a text editor (`neovim`); local documentation (`man-db`, `man-pages`, and `texinfo`); and system fonts (`terminus-font`). Last, but not least, `bash-completion` and `tmux`, for convenience.

For some latter installation steps, we’ll also install `systemd-ukify`.
```
pacstrap -K /mnt base linux linux-firmware iwd wireless-regdb intel-ucode efibootmgr dosfstools btrfs-progs neovim man-db man-pages texinfo terminus-font bash-completion tmux systemd-ukify
```

## Configuring the system

To get the filesystems mounted at startup, they need to be listed in `/etc/fstab`:
```
genfstab -U /mnt >> /mnt/etc/fstab
```

It is of the utmost importance to get it right. Execute `cat /mnt/etc/fstab` and check (carefully) its contents. It should look like
```
UUID=xxxx-xxxx  /      btrfs  subvol=@,noatime      0 0
UUID=xxxxxxxx   /home  btrfs  subvol=@home,noatime 0 0
UUID=xxxxxxxx   /boot  vfat   ...                  0 2
```

## Still configuring, now in chroot environment

Let's run:
```
arch-chroot /mnt
```
From now on, we are working inside the new installation.

### Time

```
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
```

### Locale

For the POSIX C locale, there's no need to run `locale-gen`. Just run:
```
echo 'LANG=C.UTF-8' > /etc/locale.conf
```

Also, ensure that `/etc/vconsole.conf` contains (edit with `nvim` if necessary):
```
KEYMAP=br-latin1-us
FONT=ter-132b
```

### Network

First we need to set the _hostname_:
```
echo 'tormenaArch' > /etc/hostname
```

### Bootloader

To install `systemd-boot` as the bootloader, run:
```
bootctl install
```
It should install to the _ESP_ partition (`/dev/sda1`) mounted on `/boot`.

Now we create some configuration and entry files:
```
cat << EOF > /boot/loader/loader.conf
default arch
timeout 0
editor no
EOF


cat << EOF > /boot/loader/entries/arch.conf
title   Arch Linux
linux   vmlinuz-linux
initrd  intel-ucode.img
initrd  initramfs-linux.img
options root=UUID=<UUID> rootflags=subvol=@,noatime,compress=zstd rw
EOF
```
Reaplacing _<UUID>_ with the _UUID_ of `/dev/sda2`, which can be viewed by running `blkid /dev/sda2`.

### Initramfs

Because we changed the system font and installed the bootloader, we need to recreate the _initramfs_:
```
mkinitcpio -P
```

Check `ls -lh /boot`, it should look like:
```
EFI/
loader/
intel-ucode.img
initramfs-linux.img
vmlinuz-linux
```

### Root password

Now we set a password for the _root user_:
```
paswd
```

### Final sanity check

Check the output of
```
findmnt /
findmnt /home
findmnt /boot

bootctl status

lsblk -f
```

If all checks out, then exit the chroot:
```
exit
```
Unmount the partition:
```
umount -R /mnt
```
And reboot:
```
reboot
```
Remebering to remove the installation media. This is a long boot!
