# Set up an useful environment

All commands are run as `root` within the fresh installed system. After the boot process, login as _root_ and type the _password_ defined in the last section.

First, let’s get adjust the profile and rc files:
```
cat << EOF > ~/.bash_profile
# /root/.bash_profile

# If it exists, load /root/.bashrc
if [ -f /root/.bashrc ]; then
  source /root/.bashrc
fi
EOF

cat << EOF > ~/.bashrc
# /root/.bashrc

# Some useful aliases
alias ls='ls --color=always'
alias ll='ls -hl'
alias la='ls -A'
EOF
```

To activate the aliases, run `source ~/.bashrc`.

## Some systemd setup

By default, systemd runs with a _graphical.target_. Let’s switch it to the _multi-user.target_, so _display-manager.service_ doesn’t get enabled.
```
systemctl set-default multi-user.target
systemctl isolate multi-user.target
```

## Connect to the internet and set up pacman

First, let’s configure `iwd`:
```
cat << EOF > /etc/iwd/main.conf
[General]
EnableNetworkConfiguration=true
Country=BR
EOF
```

Now, let’s start the services:
```
systemctl enable --now iwd.service
systemctl enable --now systemd-resolved.service
```

And set our domain region:
```
iw reg set BR
```

Run `iwctl` to connect to a wireless network. Refer to [install.md](install.md).

It is advisable to update the pacman database (and possibly upgrade some freshly installed package). Also, we'll enable colored output for pacman.
```
sed -i 's/^#Color$/Color/' /etc/pacman.conf
pacman -Suy
```

## Set up Snapper

First, let's download the packages:
```
pacman -S snapper snap-pac
```

Now we run
```
snapper -c root create-config /
```
to register `/` in `/etc/conf.d/snapper` (by the file `/etc/snapper/configs/root`). It also creates a new BTRFS subvolume `.snapshots` under the root (`@`) subvolume. Check it by running `btrfs subvolume list /`.

Now setting up for manual snapshots + pacman snapshots only. Edit `/etc/snapper/configs/root` so it contains:
```
TIMELINE_CREATE="no"
TIMELINE_CLEANUP="no"

NUMBER_CLEANUP="yes"
NUMBER_LIMIT="10"
NUMBER_LIMIT_IMPORTANT="5"

EMPTY_PRE_POST_CLEANUP="yes"
```

Because we do not use automatic snapshots, we can disable the timeline timer. Also, because we want to clear the pacman pre-post snapshots, we want to enable the cleanup timer:
```
systemctl disable --now snapper-timeline.timer
systemctl enable --now snapper-cleanup.timer
```

Checking:
```
snapper -c root get-config
btrfs subvolume list /
```

### Now we'll set the first manual snapshot

With this (very) minimal installation, let's create a safe point of return by creating our first (important) snapshot.

```
snapper -c root create --description "Fresh install" --userdata important=yes
```

For snapshots that may not be “important”:
```
snapper -c root create --description "Known good state"
```

Listing the snapshots:
```
snapper -c root list
```

### Systemd-ukify
```
pacman -S systemd-ukify
echo 'layout=uki' > /etc/kernel/install.conf
```

Check the existence of `/etc/kernel/cmdline` and its parameters. Run:
```
kernel-install inspect
ls -l /usr/lib/kernel/install.d/
```
If the file `91-sbctl.install` exists and is active, it should be masked. (TODO)

Regenerating the kernel installation
```
kernel-install add-all
```
