#!/bin/sh

# Dentro do ambiente chroot
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
echo 'LANG=C.UTF-8' > /etc/locale.conf
echo << EOF > /etc/vconsole.conf
KEYMAP=br-latin1-us
FONT=ter-132b
EOF

echo 'tormenaArch' > /etc/hostname

# Salvando o UUID de root (/@)
export myUUID=$(findmnt -no UUID /)

# Bootloader
bootctl install
echo "root=UUID=$myUUID rootflags=subvol=@,noatime,compress=zstd rw loglevel=3" > /etc/kernel/cmdline
echo 'layout=uki' > /etc/kernel/install.conf
kernel-install add-all
cat << EOF > /boot/loader/loader.conf
default @saved
timeout 0
editor no
EOF

