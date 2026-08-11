# Set up an useful environment

All commands are run as `root` within the fresh installed system. After the boot process, login as _root_ and type the _password_ defined in the last section.

Because we copied the network configuration files from the live envirnment, the wireless network should just work. If not, run `iwctl` and/or refer to [install.md](install.md).

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

Because we do not use automatic snapshots, we can disable the systemd timers. We can list them by:
```
systemctl list-timers 'snapper-*'
```
And remove them by
```
systemctl disable --now snapper-????.timer
```
substituting `????` by the timer actual name. Just keep the `snapper-cleanup.timer` so the pacman snapshots are kept to a maximum of 10.

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
