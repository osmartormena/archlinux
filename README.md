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

## Set up the partitions and filesystems
Set the partitions:

`cfdisk /dev/sda`

Create the filesystems:
```
mkfs.fat -F 32 /dev/sda1
mkfs.btrfs -f /dev/sda2
```
Monte e crie os subvolumes:
```
mount /dev/sda2 /mnt

btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots

umount /mnt

mount -o noatime,compress=zstd,discard=async,subvol=@ /dev/sda2 /mnt
mkdir -p /mnt/{home,.snapshots}
mount -o noatime,compress=zstd,discard=async,subvol=@home /dev/sda2 /mnt/home
mount -o noatime,compress=zstd,discard=async,subvol=@snapshots /dev/sda2 /mnt/.snapshots



mount --mkdir /dev/sda1 /mnt/boot
```

## Installation
btrfs-progs dosfstools
