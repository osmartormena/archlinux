# Installing ArchLinux from a bootable thumbdrive

All commands are run as `root` within the live environment.

## Setting keyboard mapping, console font, and system locale

Set up keyboard layout and console font
```
loadkeys br-latin1-us
setfont ter-132b
```

## Connect to the internet

If you are on a WPA Enterprise network (most likely EAP-PEAP), you must create a file `/var/lib/iwd/SSID.8021x`, substituting `SSID` by the wireless network _SSID_. This file should contain:
```
[Security]
EAP-Method=PEAP
EAP-Identity=username
EAP-PEAP-Phase2-Method=MSCHAPV2
EAP-PEAP-Phase2-Identity=username
EAP-PEAP-Phase2-Password=password

[Settings]
AutoConnect=true
```
Where `username` and `password` are the actual _username_ and _password_ for the wireless network. Then run `iwctl`.

If you are on a WPA-PSK network, just run `iwctl`.

Inside the `iwctl` prompt:
```
[iwd]# station wlan0 connect SSID
```
If it is a WPA-PSK, it will ask the password, if it is a WPA-PEAP, it should connect directly. Either way, from the `iwctl` prompt, we just quit:
```
[iwd]# quit
```

Now, we can test the network connectivity:
```
ping -c 3 ping.archlinux.org
```

## Update the system clock

Because my battery is dead, it is recommended to ensure the system clock is synchronized to prevent package signature failures. Just run `timedatectl`.

## NVRAM EFI boot entries (optional)

If you have installed (and reinstalled) distros, multiple times, trying to get it right, your NVRAM may have a lot of stale entries. Because Apple UEFI implementation don't show us the available space, it is reasonable to check if it's not too full.

Running `efibootmgr` gives me the following output:
```
BootCurrent: 0000
Timeout: 5 seconds
BootOrder: 0000,0001,0080
Boot0000* Linux Boot Manager	HD(1,GPT,c47fb772-322b-4142-8f5b-8a6783cb29ce,0x800,0x200000)/\EFI\systemd\systemd-bootx64.efi
Boot0001* Fallback Linux Boot Manager	HD(1,GPT,c47fb772-322b-4142-8f5b-8a6783cb29ce,0x800,0x200000)/\EFI\systemd\systemd-boot-fallbackx64.efi
Boot0080* Mac OS X	PciRoot(0x0)/Pci(0x1c,0x5)/Pci(0x0,0x0)/Sata(0,0,0)/HD(2,GPT,808bc55b-0bfc-49b6-88bb-0606af5df2b6,0x64028,0xe19bfb0)/VenMedia(be74fcf7-0b7c-49f3-9147-01f4042e6842,8b623a713eaff346805f37e31fe31de3)/\E22E560A-9DCE-40ED-AC11-50B0CEA13A7D\System\Library\CoreServices\boot.efi
Boot0081* Mac OS X	VenMedia(be74fcf7-0b7c-49f3-9147-01f4042e6842,4622b4566af3f746aa7104297b37fff2)/\4E774BCB-917D-4729-A7B0-CBFD09225D9F\System\Library\CoreServices\boot.efi
BootFFFF* 	PciRoot(0x0)/Pci(0x1c,0x5)/Pci(0x0,0x0)/Sata(0,0,0)/HD(2,GPT,808bc55b-0bfc-49b6-88bb-0606af5df2b6,0x64028,0xe19bfb0)/VenMedia(be74fcf7-0b7c-49f3-9147-01f4042e6842,8b623a713eaff346805f37e31fe31de3)/\8AE88CF7-EB12-34D2-A947-7868C6D8AA4C\System\Library\CoreServices\boot.efi
```

I have 5 entries: `0000` and `0001` are archlinux (the last one, a fallback); `0080`, `0081`, and `FFFF` are from Apple and I prefer not to touch them. If you have other entries, they may be removed by running `efibootmgr -b ???? -B`, where `????` is the 4-digit entry number.

To keep my NVRAM from bloating (and prevent future installation errors), I'll run:
```
efibootmgr -b 0000 -B
efibootmgr -b 0001 -B
```

## Partition the disk, create and mount the filesystems

I'll create an EFI System Partition (1 GB) and a Linux root partition, using `systemd-repart`.

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
EOF

cat << EOF > /tmp/repart.d/01-root.conf
[Partition]
Type=root
Label=Arch Linux
Format=btrfs
Compression=zstd
MakeDirectories=/@ /@home
Subvolumes=/@ /@home
DefaultSubvolume=/@
GrowFileSystem=yes
EOF
```

Before commiting to disk, check the partition layout with:
```
systemd-repart --dry-run=yes --empty=force --offline=yes --definitions=/tmp/repart.d /dev/sda
```

If everything checks out, then run:
```
systemd-repart --dry-run=no --empty=force --offline=yes --definitions=/tmp/repart.d /dev/sda
```

### Quick check of partition and subvolumes

Run and check the output:
```
lsblk -f /dev/sda
blkid /dev/sda1 /dev/sda2

mount -o subvolid=5 /dev/sda2 /mnt
btrfs subvolume list /mnt -t
umount /mnt
```

### Mount for Arch installation

Now, let's mount the filesystems for the installation
```
mount -o subvol=@,noatime,compress=zstd /dev/sda2 /mnt

mkdir /mnt/home
mount -o subvol=@home,noatime,compress=zstd /dev/sda2 /mnt/home

mkdir /mnt/boot
mount -o noatime /dev/sda1 /mnt/boot
```

And, again, a quick check by running `findmnt`.

## Installing the (bare-bones) system

We obviously need a kernel (`linux`), some firmware (`linux-firmware`), and the base system (`base`). But, we also absolutelly need `iwd`, `systemd-resolvconf`, and `wireless-regdb` for wireless networking. We should also install: CPU microcode (`intel-ucode`); filesystem utilities (`efibootmgr`, `dosfstools`, and `btrfs-progs`); a text editor (`neovim`); local documentation (`man-db`, `man-pages`, and `texinfo`); and system fonts (`terminus-font`). Last, but not least, `bash-completion` for convenience.
```
pacstrap -K /mnt base linux linux-firmware iwd systemd-resolvconf wireless-regdb intel-ucode efibootmgr dosfstools btrfs-progs neovim man-db man-pages texinfo terminus-font bash-completion
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
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux.img
options root=UUID=<BTRFS-UUID> rootflags=subvol=@,noatime,compress=zstd rw
EOF
```
Reaplacing _<BTRFS-UUID>_ with the _UUID_ of `/dev/sda2`, which can be viewed by running `blkid /dev/sda2`.

Check if an NVRAM boot entry was created `efibootmgr -v`.

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
Remebering to remove the installation media.
