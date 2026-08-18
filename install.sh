#!/bin/sh

# Atualize o relógio do sistema
timedatectl

# Partição do disco e criação dos sistemas de arquivos
mkdir /tmp/repart.d
cat << EOF > /tmp/repart.d/00-esp.conf
[Partition]
Type=esp
Label=EFI
SizeMinBytes=512M
SizeMaxBytes=512M
Format=vfat
MountPoint=/efi:defaults,noatime
EOF

cat << EOF > /tmp/repart.d/01-boot.conf
[Partition]
Type=xbootldr
Label=BOOT
SizeMinBytes=1G
SizeMaxBytes=1G
Format=vfat
MountPoint=/boot:defaults,noatime
EOF

cat << EOF > /tmp/repart.d/02-root.conf
[Partition]
Type=root
Label=ROOT
Format=btrfs
MakeDirectories=/@ /@home
Subvolumes=/@ /@home
DefaultSubvolume=/@
MountPoint=/@:defaults,noatime,compress=zstd
MountPoint=/@home:defaults,noatime,compress=zstd
Compression=zstd
EOF

systemd-repart --dry-run=no --empty=force --definitions=/tmp/repart.d --offline=yes --append-fstab=replace --generate-fstab=/tmp/fstab /dev/sda

# Montar os sistemas de arquivos para instalação
mount -o subvol=@,noatime,compress=zstd /dev/sda3 /mnt

mkdir /mnt/home
mount -o subvol=@home,noatime,compress=zstd /dev/sda3 /mnt/home

mkdir /mnt/efi
mount -o noatime /dev/sda1 /mnt/efi

mkdir /mnt/boot
mount -o noatime /dev/sda2 /mnt/boot

# Instalando o sistema
pacstrap -K /mnt linux linux-firmware base intel-ucode iwd wireless-regdb efibootmgr dosfstools btrfs-progs neovim ufw base-devel gcc-fortran git github-cli openssh systemd-ukify terminus-font man-db man-pages gnuplot tmux bash-completion

# Configurando o sistema
cp --update=all /tmp/fstab /mnt/etc/fstab
