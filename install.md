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
retorna uma lista estuturada de todos os dispositivos de armazenamento e partições reconhecidas. Caso possua um HDD ou SDD SATA, quase certamente seu dispositivo figura como `/dev/sda` (com `/dev/sda1`, `/dev/sda2`, etc. sendo suas partições). Caso possua um SSD NVMe, ele deve figurar como `/dev/nvme0n1` (com `/dev/nvme0n1p1`, `/dev/nvme0n1p2`, etc. sendo suas partições). No meu caso, o SSD é `/dev/sda`.

Nós vamos criar três partições: uma partição ESP (_EFI System Partition_) com 512 MB; uma partição do tipo _Extended Boot Loader Partition_ com 1 GB; e uma partição do tipo _root_ com o restante do disco.

Após criar o diretório
```
# mkdir /tmp/repart.d
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

Antes de escrever a nova tabela de partição e criar os novos sistemas de arquivo em disco, cheque a saída de:
```
# systemd-repart --dry-run=yes --empty=force --definitions=/tmp/repart.d --offline=yes --append-fstab=replace --generate-fstab=/tmp/fstab /dev/sda
```

Se tudo parece correto, execute (diga adeus aos dados!):
```
# systemd-repart --dry-run=no --empty=force --definitions=/tmp/repart.d --offline=yes --append-fstab=replace --generate-fstab=/tmp/fstab /dev/sda
```

Agora você deve ter seu dispositivo corretamente particionado e um arquivo `/tmp/fstab` foi gerado. Pela ordem das operações, tenho: `/efi` em `/dev/sda1`; `/boot` em `/dev/sda2`; e os subvolumes BTRFS em `/dev/sda3`.

> [!Info]
> Como estamos usando sistemas de arquivo FAT32 e BTRFS, precisamos dessas ferramentas no sistema. Instale os pacotes `dosfstools` e `btrfs-progs`.

### Montar os sistemas de arquivos para instalação

Como estamos operando a partir da live ISO, vamos montar o dispositivo recém particionado em `/mnt`. 
```
# mount -o subvol=@,noatime,compress=zstd /dev/sda3 /mnt

# mkdir /mnt/home
# mount -o subvol=@home,noatime,compress=zstd /dev/sda3 /mnt/home

# mkdir /mnt/efi
# mount -o noatime /dev/sda1 /mnt/efi

# mkdir /mnt/boot
# mount -o noatime /dev/sda2 /mnt/boot
```

Cheque, cuidadosamente, a saída dos seguinte comandos:
```
lsblk -f
findmnt
blkid /dev/sda1 /dev/sda2 /dev/sda3
cat /tmp/fstab
btrfs subvolume list /mnt -t
```

## Instalando o sistema

Aqui vou listar um bom número de pacotes que serão instalados no sistema. O racional para a escolha de cada um deles será exposto e, quando possível, escolhas alternativas serão apresentadas.

* Segundo a documentação oficial, são absolutamente imprescindíveis: o _kernel_ `linux`; _firmware_ `linux-firmware`; e uma coleção básica de pacotes `base`.
* É altamente recomendável instalar atualizações de micro-código da CPU: ou `intel-ucode` ou `amd-ucode`, dependendo da sua CPU.
* Caso seu computador não possua uma porta Ethernet, sua conexão sem fio também deve estar funcional já a partir da instalação: recomendo instalar `iwd` e `wireless-regdb`.
* Com base em nosso sistema de arquivos, instale: `efibootmgr`, `dosfstools` e `btrfs-progs`.
* Você __deve__ instalar um editor de texto: `nano` é uma boa opção; eu uso `neovim` pois minhas ferramentas de produtividade estão ligadas a ele.
* É sempre recomendável instalar um _firewall_: `ufw` é descomplicado até no nome.
* Ferramentas de desenvolvimento e acesso ao <github.com>: `base-devel`, `gcc-fortran`, `git`, `github-cli` e `openssh`.
* A instalação de um _bootloader_ descrita mais adiante depende do pacote `systemd-ukify`.
* A família de fonte Terminus é excelente para suporte diacrítico e legibilidade. Instale o pacote `terminus-font`.
* Considero imprescindível ter a documentação local de todos o sistema: os pacotes `man-db` e `man-pages` dão acesso à documentação de cada comando e arquivo de configuração aqui referenciado.
* Finalmente, algumas ferramentas de conveniência: `tmux` é muito útil para trabalhar no console; `bash-completion` ajuda a evitar a síndrome de tunel do carpo.

Obviamente, essa lista de pacotes pode ser alterada e/ou extendida conforme sua necessidade e conveniência.

O comando a seguir fará a instalação dos pacotes na raiz (subvolume padrão `/@`), montada em `/mnt`. A opção `-K` cria um novo _keyring_ para validação de pacotes na nova instalação.
```
# pacstrap -K /mnt linux linux-firmware base intel-ucode iwd wireless-regdb efibootmgr dosfstools btrfs-progs neovim ufw base-devel gcc-fortran git github-cli openssh systemd-ukify terminus-font man-db man-pages tmux bash-completion
```

## Configurando o sistema

Precisamos fazer alguns ajustes finais para que o sistema recém instalado seja funcional. A tabela de sistemas de arquivo criadas durante o particionamento do disco precisam ser copiadas para o novo sistema. Como já existe um _stub_ de instalação em `/mnt/etc/fstab`, é necessário sobrescrevê-lo com a opção `--update=all`.
```
# cp --update=all /tmp/fstab /mnt/etc/fstab
```

Para evitar a reinserção das credenciais de rede, novamente, após o primeiro _boot_ do sistema, podemos copiar os arquivos `.open`, `.psk`, ou `.8021x` da live ISO para o novo sistema. Primeiro, criamos o diretório onde eles devem ser armazenados e depois copiados (novamente, substituindo `SSID` e a extensão conforme o seu caso).
```
# mkdir /mnt/var/lib/iwd
# cp /var/lib/iwd/SSID{.open,.psk,.8021x} /mnt/var/lib/iwd/
```

## Ainda configurando, agora no ambiente 'chroot'

Alguns passos da configuração não podem ser feitos “de fora dela”. Então vamos ingressar no sistema recém instalado através de um mecanimso conhecido como 'chroot'. A opção `-S` é necessária para a correta instalação do _bootloader_.
```
# arch-chroot -S /mnt
```
Deste ponto em diante, nossos comandos não são mais executados no ambiente live ISO, mas no ambiente recém instalado.

### Time

Por padrão, o ArchLinux mantém seu relógio de sistema sincronizado ao UTC, embora ainda mostre a hora de usuário de acordo com o fuso horário local. Aqui no estado do Paraná, a presente configuração basta.
```
# ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
# hwclock --systohc
```

### Locale

Por simplicidade, neste momento, vamos manter o local padrão: POSIX C.
```
# echo 'LANG=C.UTF-8' > /etc/locale.conf
```

Também crie o arquivo `/etc/vconsole.conf` (usando seu editor de texto “favorito”) e ajuste seu conteúdo para
```
KEYMAP=br-latin1-us
FONT=ter-132b
```
lembrando de ajustar para o seu _layout_ de teclado e tamanho de fonte, conforme na primeira seção.

### Rede

É necessário definir um nome de host (_hostname_). Para evitar problemas, escolha um nome único, improvável de ser replicado em alguma rede que esteja conectado. Para mim, o _hostname_ é `tormenaArch`. Escolha um que te sirva e substitua abaixo.
```
# echo 'tormenaArch' > /etc/hostname
```

### Bootloader

Vamos usar o `systemd-boot` como _bootloader_. Execute
```
# bootctl install
```
Isso deve ajustar as variáveis na NVRAM e copiar aluns arquivos para a partição ESP (`/dev/sda1`) montada em `/efi`, para a partição BOOT (`/dev/sda2`) montada em `/boot`.

Crie o arquivo `/etc/kernel/cmdline` contendo `root=UUID=<UUID> rootflags=subvol=@,noatime,compress=zstd rw loglevel=3`. Substitua <UUID> pela UUID da partição raiz, contida em `/etc/fstab`.

Criando o arquivo `/etc/kernel/install.conf`
```
# echo 'layout=uki' > /etc/kernel/install.conf
```
é suficiente para que o `systemd-boot` utilize uma UKI (_Unified Kernel Image_) para fazer o _boot_.

Executando
```
# kernel-install add-all
```
cria uma UKI para cada _kernel_ disponível em `/usr/lib/modules` e instala sob `/boot/EFI/Linux`. A UKI pode ser inspecionada por:
```
# ukify inspect /boot/EFI/Linux/*.efi
```

Finalmente, crie o arquivo `/boot/loader/loader.conf`, contendo:
```
default @saved
timeout 0
editor no
```
e cheque se sua opção de _boot_ aparece para o __systemd-boot__:
```
# bootctl list
```

### Senha de 'root'

Vamos agora criar uma senha do usuário __root__ neste sistema (não se esqueça desta senha):
```
# passwd
```

### Checando a sanidade da instalação

Averigue (para inconsistências) a saída dos comandos:
```
# findmnt /
# findmnt /home
# findmnt /efi
# findmnt /boot

# bootctl status

# lsblk -f
```

Se tudo estiver certo, saia do ambiente 'chroot':
```
# exit
```

De volta à live ISO, desmonte as partições sob `/mnt`
```
# umount -R /mnt
```
e reinicie
```
# reboot
```

> [!Important]
> Lembre de remover a mídia de instalação!
