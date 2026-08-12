# Notes and step-by-step installation of ArchLinux on a MacBookPro12,1: Matlab® (R2026a) working on a Debian 13 (Trixie) chroot

In this repo I'm starting with the 2026-08-01 archlinux live ISO, but it should work with any version. I'll not go into details of how to create a bootable live thumb drive, as that is very well documented.

The order of most operations follows the official installation guide. The detours from the defaults used AI as an initial approximation, but were checked by (current, at the time of this writing) documentation — which, on a rolling release, may very well be a moving target!

## Booting the live ISO and installing the system

This section pertains only to the bootable installation media. All commands are run as _root_. It is contained on [Install.md](install.md).

## First boot configuration and additional packages installation

This section runs directly on the fresh installed (minimal) system. All commands are (also) run as _root_. It is contained in [FirstBoot.md](firstboot.md).
