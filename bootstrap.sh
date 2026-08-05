#!/bin/sh
# Basic post-install system bootstraping, must be run by root.

# Firewall
systemctl start ufw
systemctl enable ufw

# Set up bash_profile and bashrc
cat << EOF > ~/.bash_profile
# Source ~/.bashrc if it exists
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi
fastfetch
EOF

cat << EOF > ~/.bashrc
# Usefull aliases
alias ls='ls --color=always --human-readable'
alias ll='ls -l'
alias la='ls -A'
alias vim='nvim'
alias ff='fastfetch'
EOF

# systemd units configuration
sed -i 's/^timeout 3$/timeout 0/' /boot/loader/loader.conf
sed -i 's/relatime/noatime/g' /etc/fstab
systemctl set-default multi-user.target
echo 700 > /sys/class/backlight/intel_backlight/brightness
echo 128 > /sys/class/leds/smc\:\:kbd_backlight/brightness
