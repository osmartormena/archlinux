# Installing ArchLinux from a bootable thumbdrive

All commands are run as `root` within the live environment.

## Setting keyboard mapping, console font, and system locale

Set up keyboard layout and console font
```
loadkeys br-latin1-us
setfont ter-132b
```

## Connect to the internet

If you are on a WPA Enterprise network (most likely EAP-PEAP), you must create a file `/var/lib/iwd/SSID.8021x`, substituting `SSID` by the wireless network _SSID_. This file should contain:
```
[Security]
EAP-Method=PEAP
EAP-Identity=username
EAP-PEAP-Phase2-Method=MSCHAPV2
EAP-PEAP-Phase2-Identity=username
EAP-PEAP-Phase2-Password=password

[Settings]
AutoConnect=true
```
Where `username` and `password` are the actual _username_ and _password_ for the wireless network. Then run `iwctl`.

If you are on a WPA-PSK network, just run `iwctl`.

Inside the `iwctl` prompt:
```
[iwd]# station wlan0 connect SSID
```
If it is a WPA-PSK, it will ask the password, if it is a WPA-PEAP, it should connect directly. Either way, from the `iwctl` prompt, we just quit:
```
[iwd]# quit
```

Now, we can test the network connectivity:
```
ping -c 3 ping.archlinux.org
```

## Update the system clock

Because my battery is dead, it is recommended to ensure the system clock is synchronized to prevent package signature failures. Just run `timedatectl`.

## NVRAM EFI boot entries (optional)

If you have installed (and reinstalled) distros, multiple times, trying to get it right, your NVRAM may have a lot of stale entries. Because Apple UEFI implementation don't show us the available space, it is reasonable to check if it's not too full.

Running `efibootmgr` gives me the following output:
```
BootCurrent: 0000
Timeout: 5 seconds
BootOrder: 0000,0001,0080
Boot0000* Linux Boot Manager	HD(1,GPT,c47fb772-322b-4142-8f5b-8a6783cb29ce,0x800,0x200000)/\EFI\systemd\systemd-bootx64.efi
Boot0001* Fallback Linux Boot Manager	HD(1,GPT,c47fb772-322b-4142-8f5b-8a6783cb29ce,0x800,0x200000)/\EFI\systemd\systemd-boot-fallbackx64.efi
Boot0080* Mac OS X	PciRoot(0x0)/Pci(0x1c,0x5)/Pci(0x0,0x0)/Sata(0,0,0)/HD(2,GPT,808bc55b-0bfc-49b6-88bb-0606af5df2b6,0x64028,0xe19bfb0)/VenMedia(be74fcf7-0b7c-49f3-9147-01f4042e6842,8b623a713eaff346805f37e31fe31de3)/\E22E560A-9DCE-40ED-AC11-50B0CEA13A7D\System\Library\CoreServices\boot.efi
Boot0081* Mac OS X	VenMedia(be74fcf7-0b7c-49f3-9147-01f4042e6842,4622b4566af3f746aa7104297b37fff2)/\4E774BCB-917D-4729-A7B0-CBFD09225D9F\System\Library\CoreServices\boot.efi
BootFFFF* 	PciRoot(0x0)/Pci(0x1c,0x5)/Pci(0x0,0x0)/Sata(0,0,0)/HD(2,GPT,808bc55b-0bfc-49b6-88bb-0606af5df2b6,0x64028,0xe19bfb0)/VenMedia(be74fcf7-0b7c-49f3-9147-01f4042e6842,8b623a713eaff346805f37e31fe31de3)/\8AE88CF7-EB12-34D2-A947-7868C6D8AA4C\System\Library\CoreServices\boot.efi
```

I have 5 entries: `0000` and `0001` are archlinux (the last one, a fallback); `0080`, `0081`, and `FFFF` are from Apple and I prefer not to touch them. If you have other entries, they may be removed by running `efibootmgr -b ???? -B`, where `????` is the 4-digit entry number.

To keep my NVRAM from bloating (and prevent future installation errors), I'll run:
```
efibootmgr -b 0000 -B
efibootmgr -b 0001 -B
```

## Partition the disk

A
