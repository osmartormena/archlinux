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
