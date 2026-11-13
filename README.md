# Instalação do ArchLinux em um MacBook Pro 13" (Early 2015)

## _Boot_ da live ISO do ArchLinux

Para o _layout_ de teclado operar naturalmente com acentos, til e cedilha, é necessário configurá-lo adequadamente. Também é necessário usar uma fonte que suporte os acentos. Devido à alta resolução do Retina Display (227 dpi), vou usar uma fonte da família Terminus.

```
# loadkeys br-latin1-us
# setfont ter-132b
```

### Conecte-se à Internet

Para garantir o funcionamento do WiFi nas bandas de 5 GHz é necessário respeitar a canalização e os limites de potência nacionais. O pacote `wireless-regdb` provê essas informações. Execute
```
iw reg set BR
```

Vamos averiguar o nome do dispositivo de rede. Executando
```
iwctl device list
```
é retornado uma lista de dispositivos de rede, provavelmente com um único item. Neste caso `wlan0`. Agora, executando
```
iwctl station wlan0 scan
iwctl station wlan0 get-networks
```
deve resultar em uma lista de redes (SSID) sem fio ao alcance.

#### Para redes abertas

Para se conectar a uma rede aberta, basta executar
```
iwctl station wlan0 connect SSID
```
Um arquivo `/var/lib/iwd/SSID.open` é criado com a configuração desta rede.

#### Para redes WPA-Personal

Para se conectar, execute:
```
iwctl --passphrase=PASSPHRASE station wlan0 connect SSID
```
Um arquivo `/var/lib/iwd/SSID.psk` é criado com a configuração desta rede.

#### Para redes empresariais (WPA-Enterprise)

Agora, infelizmente, o utilitário `iwctl` sozinho não é capaz de autenticar a conexão. É necessário provisionar manualmente um arquivo `/var/lib/iwd/SSID.8021x`. Execute `vim /var/lib/iwd/SSID.8021x` e preencha com o seguinte conteúdo:
```
[Security]
EAP-Method=PEAP
EAP-Identity=·······
EAP-PEAP-Phase2-Method=MSCHAPV2
EAP-PEAP-Phase2-Identity=·······
EAP-PEAP-Phase2-Password=···············
```
Agora, basta executar
```
iwctl station wlan0 connect SSID
```
para se conectar à rede.

#### Testando a conectividade

```
ping -c 3 google.com
```

### Variáveis de boot EFI na NVRAM

Executando `efibootmgr`, produz a seguinte saída:
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

Possuo 5 variáveis de _boot_ EFI: `Boot0000` e `Boot0001` são do ArchLinux (a segunda, um _fallback_ caso um novo _kernel_ apresente problemas); `Boot0080`, `Boot0081` e `BootFFFF` são da Apple. Como a UEFI da Apple não segue rigorosamente os padrões, melhor preservar essas variáveis.

Ao reinstalar o sistema, para evitar que minha NVRAM fique cheia de variáveis espúrias, remova as entradas `Boot0000` e `Boot0001`, através dos comandos:
```
efibootmgr -b 0000 -B
efibootmgr -b 0001 -B
```

### Executando o script automático de instalação

Vamos atualizar o `archinstall` e executá-lo:
```
pacman -S archinstall
archinstall
```
Uma interface textual será aberta. Vamos ajustar as opções uma-a-uma.
- __Archinstall language:__ `English`
- __Locales__
  - __Keyboard layout:__ `br-latin-us`
  - __Locale language:__ `en_US.UTF-8`
  - __Locale encoding:__ `UTF-8`
  - __Console font:__ `ter-132b`
- __Mirrors and repositories__: _não altere_
- __Disk configuration > Partitioning > Use a best effort default partition layout:__ _Selecione seu dispositivo_
  - __Select main filesystem:__ `btrfs`
    - __Would you like to use BTRFS subvolumes with a default structure?__ `Yes`
    - __Would you like to use compression or disable CoW?__ `Use compression`
  - __LVM:__ _não altere_
  - __Disk encryption:__ _não altere_
  - __Btrfs snapshots:__ _não altere_
- __Swap:__ _não altere_
- __Bootloader__
  - __Bootloader:__ `Systemd-boot`
  - __Unified kernel images:__ `Yes`
  - __Plymouth:__ _Confirme a mensagem de aviso (`Yes`)_
    - __Select Plymouth theme:__ `bgrt`
- __Kernels:__ _não altere_
- __Additional firmware:__ _não altere_
- __Hostname:__ _defina conforme conveniente_
- __Authentication__
  - __Root password:__ _defina sua senha de root_
  - __User account:__ _não defina um usuário aqui_
  - __U2F login setup:__ _não altere_
- __Profile__
  - __Type:__ `Xorg`
  - __Graphics driver:__ `Intel (open source)`
- __Applications__
  - __Bluetooth:__ `Yes`
  - __Audio:__ `pipewire`
  - __Print service:__ `Yes`
  - __Power management:__ `power-profiles-daemon`
  - __Firewall:__ `ufw`
  - __Additional fonts:__ _selecione todas_
- __Network configuration:__ `Use standalone iwd`
- __Pacman:__ _não altere_
- __Additional packages__
  - A
[!Note]
Pacotes `base`, `linux`, `linux-firmware`, e adicionais de __Profile__ e __Applications__ já são instalados.
- __Timezone:__ `America/Sao_Paulo`
- __Automatic time sync (NTP):__ _não altere_
- __Install__

* Segundo a documentação oficial, são absolutamente imprescindíveis: o _kernel_ `linux`; _firmware_ `linux-firmware`; e uma coleção básica de pacotes `base`.
* É altamente recomendável instalar atualizações de micro-código da CPU: ou `intel-ucode` ou `amd-ucode`, dependendo da sua CPU.
* Caso seu computador não possua uma porta Ethernet, sua conexão sem fio também deve estar funcional já a partir da instalação: recomendo instalar `iwd` e `wireless-regdb`.
* Com base em nosso sistema de arquivos, instale: `efibootmgr`, `dosfstools` e `btrfs-progs`.
* Você __deve__ instalar um editor de texto: `nano` é uma boa opção; eu uso `neovim` pois minhas ferramentas de produtividade estão ligadas a ele.
* É sempre recomendável instalar um _firewall_: `ufw` é descomplicado até no nome.
* Ferramentas de desenvolvimento e acesso ao <github.com>: `base-devel`, `gcc-fortran`, `git`, `github-cli` e `openssh`.
* A família de fonte Terminus é excelente para suporte diacrítico e legibilidade. Instale o pacote `terminus-font`.
* Considero imprescindível ter a documentação local de todos o sistema: os pacotes `man-db` e `man-pages` dão acesso à documentação de cada comando e arquivo de configuração aqui referenciado.
* O pacote `gnuplot` é utilizado em meu fluxo de trabalho com o TeX Live.
* Finalmente, algumas ferramentas de conveniência: `tmux` é muito útil para trabalhar no console; `bash-completion` ajuda a evitar a síndrome de tunel do carpo.

## Primeiro _boot_
