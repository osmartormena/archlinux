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
MAC_ID=$(systemd-id128 new)
echo $MAC_ID > /tmp/machine_id

cat << EOF > /etc/repart.d/00-disk.conf
[Partition]
Type=esp
Label=ESP
SizeMinBytes=1G
SizeMaxBytes=1G
Format=vfat
MountPoint=/boot
EOF

cat << EOF > /etc/repart.d/01-disk.conf
[Partition]
Type=root
Label=ROOT
Format=ext4
MountPoint=/
EOF

systemd-repart --dry-run=no --empty=force --seed=$MAC_ID --generate-fstab=/tmp /dev/sda

mount --mkdir
mount

cp /tmp/fstab /mnt/etc/fstab
cp /tmp/machine_id /mnt/etc/machine_id
```
