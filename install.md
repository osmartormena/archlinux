# Instalando o ArchLinux de um ___thumbdrive___

Todos os comandos são executados como usuário __root__. A mídia de instalação possui uma pluralidade de pacotes disponíveis. Eles não são automaticamente instalados no sistemas, apenas os requeridos. Nas seções a seguir, o racional para a escolha específica de alguns pacotes serão destacadas.

## Ajustando o ___layout___ do teclado e fonte do console

> [!Note]
> Em razão da alta resolução (227 DPI) do Retina Display, bem como a disposição específica do teclado do MBP ANSI, as opções aqui utilizadas não são universais. Consulte a documentação.

Para o _layout_ de teclado operar naturalmente com acentos, til e cedilha, é necessário configurar o `loadkeys` adequadamente. O diretório `/usr/share/kbd/keymaps` contém todos os _layouts_ disponíveis.

A escolha da fonte é mais pessoal: certifique-se de usar uma fonte que suporte acentos, til e cedilha. Recomendo uma fonte da família Terminus. Minha é pautada pela altíssima resolução do Retina Display e a fonte deve parecer enrome em monitores convencionais. O diretório `/usr/share/kbd/consolefonts`, contém as fontes. Tente uma das seguintes opções: `ter-114b`, `ter-116b`, `ter-118b`, `ter-120b`, `ter-122b`, `ter-124b`, `ter-128b`, ou `ter-132b`.

```
# loadkeys br-latin1-us
# setfont ter-132b
```

> [!Info]
> O pacote `terminus-font` precisará ser instalado para esta fonte estar disponível no sistema.

## Conecte-se à Internet

Uma conexão cabeada deve ser reconhecida automaticamente. Esta seção trata exclusivamente de uma conexão sem fio.

> [!Note]
> O módulo sem fio da Broadcom, utilizado no MBP, possui uma notória e conturbada história acerca de seus _drivers_ e suporte no _kernel_ do Linux. Há um excesso de zelo na instruções desta seção para garantir a plena funcionalidade dos canais de 5 GHz (e, futuramente, também 6 GHz).

Para garantir o funcionamento do WiFi nas bandas de 5 GHz (ou 6 GHz) é necessário respeitar a canalização e os limites de potência nacionais. O pacote `wireless-regdb` provê essas informações. Executando
```
# iw reg set BR
```
garante a visibilidade das bandas além de 2,4 GHz.

Vamos averiguar o nome do dispositivo de rede. Executando
```
# iwctl device list
```
é retornado uma lista de dispositivos de rede, provavelmente com um único item. No meu caso, o nome é `wlan0`. Agora, executando
```
# iwctl station wlan0 scan
# iwctl station wlan0 get-networks
```
deve resultar em uma lista de redes sem fio ao alcance. Os nomes de rede são chamados de SSIDs. Nas subseções a seguir, substitua `SSID` pelo seu nome de rede. Caso sua rede seja oculta, consulte a documentação para conectar a uma BSSID.

### Para redes abertas

Redes abertas não possuem segurança (senha). Para se conectar a uma rede aberta, basta executar
```
# iwctl station wlan0 connect SSID
```
Um arquivo `/var/lib/iwd/SSID.open` é criado com a configuração desta rede.

### Para redes pessoais com senha (WPA-Personal)

Para uma rede WPA-PSK (_Wi-Fi Protected Access Pre-Shared Key_), é necessário conhecer a senha (__PASSPHRASE__) da rede para autenticar a conexão. Para se conectar, execute:
```
# iwctl --passphrase=PASSPHRASE station wlan0 connect SSID
```
Um arquivo `/var/lib/iwd/SSID.psk` é criado com a configuração desta rede.

### Para redes empresariais (WPA-Enterprise)

Em ambientes empresariais e universidades (incluindo a UTFPR), a autenticação da rede sem fio é feita usando credenciais personalizadas, ao invés de uma única senha compartilhada. Há vários modelos de operação. Aqui será exemplificado o WPA-PEAP (_WPA Protected Extensible Authentication Protocol_), bastante comum e utilizado na UTFPR.

Agora, infelizmente, o utilitário `iwctl` sozinho não é capaz de autenticar a conexão. É necessário provisionar manualmente um arquivo `/var/lib/iwd/SSID.8021x`. Para tal, vamos utilizar um editor de texto. A live ISO possui dois: `nano` e `vim`. Se você nunca ouviu falar do `vim`, melhor usar o `nano` (eu retornarei neste tópico depois). Assim, a seu critério, execute `nano /var/lib/iwd/SSID.8021x` ou `vim /var/lib/iwd/SSID.8021x` (substituindo __SSID__ pelo nome da rede) e preencha com o seguinte conteúdo:
```
[Security]
EAP-Method=PEAP
EAP-Identity=·······
EAP-PEAP-Phase2-Method=MSCHAPV2
EAP-PEAP-Phase2-Identity=·······
EAP-PEAP-Phase2-Password=···············
```
Preenchendo adequadamento `EAP-Identity` e `EAP-PEAP-Phase2-Identity` com seu nome de usuário e `EAP-PEAP-Phase2-Password` com sua senha. Agora, basta executar
```
# iwctl station wlan0 connect SSID
```
para se conectar à rede.

### Testando a conectividade

Se tudo estiver ok, não devemos perder nenhum `ping`.
```
# ping -c 3 google.com
```

> [!Info]
> Os pacotes `iwd` e `wireless-regdb` precisarão ser instalados.

## Atualize o relógio do sistema

É altamente recomendável certificar-se que o relógio do sistema está sincronizado. Isso evita erros de checagem de assinatura nos pacotes. Execute:
```
# timedatectl
```

## (Opcional) variáveis de ___boot___ EFI na NVRAM

> [!Warning]
> As ações desta seção podem deixar muito difícil a recuperação do sistema e dos dados presentes nele. Sempre tenha um _backup_.

Caso você já tenha feito algumas instalações de distribuições Linux, BSD, macOS ou Windows (com ou sem _dual boot_), é provável que sua NVRAM esteja repleta de variáveis referentes à essas instalações antigas. Como muitas implementações da UEFI não mostra o espaço disponível na NVRAM, caso ela fique cheia, é possível ter problemas com novas instalações.

Caso você esteja instalando o ArchLinux como _dual boot_, seja extremamente cuidadoso aqui, pois você pode remover a variável que permite seu outro sistema operacional fazer _boot_. Melhor deixar a NVRAM como está. Caso queria usar o ArchLinux como seu único sistema operacional, os passos a seguir são perfeitamente seguros.

Executando `efibootmgr` em meu computador, produz a seguinte saída (truncada por simplicidade e legibilidade):
```
BootCurrent: 0000
Timeout: 5 seconds
BootOrder: 0000,0001,0080
Boot0000* Linux Boot Manager	…
Boot0001* Fallback Linux Boot Manager	…
Boot0080* Mac OS X	…
Boot0081* Mac OS X	…
BootFFFF* 	…
```

Vejam que eu possuo 5 variáveis de _boot_ EFI: `Boot0000` e `Boot0001` são do ArchLinux (a segunda, um _fallback_ caso um novo _kernel_ apresente problemas); `Boot0080`, `Boot0081` e `BootFFFF` são da Apple. Como a UEFI da Apple não segue rigorosamente os padrões, prefiro preservar essas variáveis.

Caso eu deseje reinstalar o sistema, para evitar que minha NVRAM fique cheia de variáveis espúrias, posso remover as entradas `Boot0000` e `Boot0001`, através dos comandos:
```
# efibootmgr -b 0000 -B
# efibootmgr -b 0001 -B
```

> [!Info]
> O pacote `efibootmgr` precisa ser instalado no sistema, caso queira utilizá-lo depois.

## Partição do disco e criação dos sistemas de arquivos

> [!Caution]
> As ações desta seção apagam irrecuperavelmente os dados nas partições de disco onde são aplicadas. Sempre tenha um _backup_ de seus dados.

O caso mais simples é uma instalação usando todo o disco. Caso esteja fazendo um _dual boot_, sugiro seguir __atentamente__ as instruções oficiais. As instruções são válidas tanto para SSD quanto para HDD.

Primeiro, precisamos averiguar o nome do dispositivo que representa o SSD (ou HDD) no sistema. Executando
```
# lsblk
```
retorna uma lista estuturada de todos os dispositivos de armazenamento e partições reconhecidas. Caso possua um HDD ou SDD SATA, quase certamente seu dispositivo figura como `/dev/sda` (com `/dev/sda1`, `/dev/sda2`, etc. sendo suas partições). Caso possua um SSD NVMe, ele deve figurar como `/dev/nvme0n1` (com `/dev/nvme0n1p1`, `/dev/nvme0n1p2`, etc. sendo suas partições).

Nós vamos criar três partições: uma partição ESP (_EFI System Partition_) com 512 MB; uma partição do tipo _Extended Boot Loader Partition_ com 1 GB; e uma partição do tipo _root_ com o restante do disco.

Após criar o diretório
```
mkdir /tmp/repart.d
```
vamos criar, usando nosso editor de texto “favorito” (`nano` ou `vim`), os seguintes arquivos: `/tmp/repart.d/00-esp.conf`, contendo:
```
[Partition]
Type=esp
Label=EFI
SizeMinBytes=512M
SizeMaxBytes=512M
Format=vfat
MountPoint=/efi:defaults,noatime
```
Aqui, alguns atributos são auto-descritivos. O `Label` é cosmético e pode ser alterado para qualquer coisa que te agrade. o `Format=vfat` é obrigatório, pois a UEFI só reconhece os formatos `FAT12`, `FAT16` e `FAT32`, e o `vfat` escolhe um deles, baseado no tamanho da partição. O atributo `MountPoint` define onde este sistema de arquivos será montado na hierarquia, bem como suas opções de montagem: os _defaults_ são bem racionais e a opção `noatime` ajuda muito com a vida útil de SSDs.

O arquivo `/tmp/repart.d/01-boot.conf` possui estrutura muito similar:
```
[Partition]
Type=xbootldr
Label=BOOT
SizeMinBytes=1G
SizeMaxBytes=1G
Format=vfat
MountPoint=/boot:defaults,noatime
```

E, finalmente, vamos definir a partição _root_ (raiz) através do arquivo `/tmp/repart.d/02-root.conf`:
```
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
```
Aqui, já temos outras opções: o formato `btrfs` é um sistema de arquivos moderno, confiável e com algumas funcionalidades muito úteis. Esta partição será dividida em dois subvolumes (`/@` e `/@home`) separando o sistema das pastas pessoais de usuário(s). Uma das vantagens do `btrfs` é o suporte nativo a compressão do sistema de arquivos. Essa compressão é feita com mínimo _overhead_ computacional, oferecendo benefícios ao gargalo (lento) de leituras e escritas em disco, bem como maior longevidade. Ela também suporta a encriptação nativa dos arquivos pessoais, sem a necessidade da encriptação de todo o disco.

Before commiting to disk, check the partition layout with:
```
systemd-repart --dry-run=yes --empty=force --definitions=/tmp/repart.d --offline=yes --append-fstab=replace --generate-fstab=/tmp/fstab /dev/sda
```

If everything checks out, then run:
```
systemd-repart --dry-run=no --empty=force --definitions=/tmp/repart.d --offline=yes --append-fstab=replace --generate-fstab=/tmp/fstab /dev/sda
```

Because we used a FAT32 and a BTRFS filesystems, we need to push _dosfstools_ and _btrfs_progs_ to our packages stack.

### Mount for Arch installation

Now, let's mount the filesystems for the installation
```
mount -o subvol=@,noatime,compress=zstd /dev/sda3 /mnt

mkdir /mnt/home
mount -o subvol=@home,noatime,compress=zstd /dev/sda3 /mnt/home

mkdir /mnt/efi
mount -o noatime /dev/sda1 /mnt/efi

mkdir /mnt/boot
mount -o noatime /dev/sda2 /mnt/boot
```

Quick check the partition and subvolumes:
```
lsblk -f /dev/sda
findmnt
blkid /dev/sda1 /dev/sda2 /dev/sda3
cat /tmp/fstab
btrfs subvolume list /mnt -t
```

## Installing the (bare-bones) system

Now it’s time to pop our package stack. We obviously need a kernel (`linux`), some firmware (`linux-firmware`), and the base system (`base`). But, we also absolutelly need `iwd` and `wireless-regdb` for wireless networking. We should also install: CPU microcode (`intel-ucode`); filesystem utilities (`efibootmgr`, `dosfstools`, and `btrfs-progs`); development tools (`base-devel`); a text editor (`neovim`); local documentation (`man-db` and `man-pages`); and system fonts (`terminus-font`). Last, but not least, `bash-completion` and `tmux`, for convenience.

For some latter installation steps, we’ll also install `systemd-ukify`.
```
pacstrap -K /mnt base linux linux-firmware iwd wireless-regdb intel-ucode efibootmgr dosfstools btrfs-progs base-devel neovim man-db man-pages terminus-font bash-completion tmux systemd-ukify
```

## Configuring the system

Let’s copy our *systemd-repart* generated _fstab_ to the freshly installed system.
```
cp --update=all /tmp/fstab /mnt/etc/fstab
```

While we are at it, let’s also copy the live iso network configuration
```
mkdir /mnt/var/lib/iwd
cp /var/lib/iwd/SSID.psk /mnt/var/lib/iwd/SSID.psk
```
changing _SSID_ appropriately.

## Still configuring, now in chroot environment

Let's run:
```
arch-chroot -S /mnt
```
From now on, we are working inside the new installation.

### Time

```
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
```

### Locale

For the POSIX C locale, there's no need to run `locale-gen`. Just run:
```
echo 'LANG=C.UTF-8' > /etc/locale.conf
```

Also, ensure that `/etc/vconsole.conf` contains (edit with `nvim` if necessary):
```
KEYMAP=br-latin1-us
FONT=ter-132b
```

### Network

First we need to set the _hostname_:
```
echo 'tormenaArch' > /etc/hostname
```

### Bootloader

To install `systemd-boot` as the bootloader, run:
```
bootctl install
```
It should install to the _ESP_ partition (`/dev/sda1`) mounted on `/efi`, to the _XBOOTLDR_ partition (`/dev/sda2`) mounted on `/boot`.

Create the file `/etc/kernel/cmdline` with the contents `root=UUID=<UUID> rootflags=subvol=@,noatime,compress=zstd rw loglevel=3`. The _UUID_ from the root filesystem can be copied from `/etc/fstab`.

Now we create `/etc/kernel/install.conf`:
```
echo 'layout=uki' > /etc/kernel/install.conf
```

Running
```
kernel-install add-all
```
creates the UKI, which may be found at `/boot/EFI/Linux`, and can be inspected by:
```
ukify inspect /boot/EFI/Linux/*.efi
```

Finally, create `/boot/loader/loader.conf`
```
cat << EOF > /boot/loader/loader.conf
default @saved
timeout 0
editor no
EOF
```
and check what *systemd-boot* sees by:
```
bootctl list
```

### Root password

Now we set a password for the _root user_:
```
passwd
```

### Final sanity check

Check the output of
```
findmnt /
findmnt /home
findmnt /efi
findmnt /boot

bootctl status

lsblk -f
```

If all checks out, then exit the chroot:
```
exit
```
Unmount the partition:
```
umount -R /mnt
```
And reboot:
```
reboot
```
Remebering to remove the installation media. This is a long boot!
