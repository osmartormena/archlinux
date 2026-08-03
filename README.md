# archlinux-macbookpro12.1
My personal step-by-step installation of ArchLinux on my early 2015 MBP.

## Boot archlinux 2026-08-01 live ISO image
Set up keyboard layout and console font:
```
loadkeys us-acentos
setfont ter-132b
```

Ensure time synchronization is set:

`timedatectl`

## Set up the partitions
Set the machine ID, partitions, and file systems:
```
mkdir -p /tmp/target/etc/repart.d
cat << EOF > /tmp/target/etc/repart.d/00-disk.conf
[Partition]
Type=esp
Label=ESP
SizeMinBytes=512M
SizeMaxBytes=1G
Format=vfat

[Partition]
Type=root
Label=ROOT
Format=btrfs
EOF

MAC_ID=$(systemd-id128 new)
echo $MAC_ID > /tmp/machine_id
```

### chroot
`cp /tmp/machine_id /etc/machine_id`
