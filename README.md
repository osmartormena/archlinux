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

```
