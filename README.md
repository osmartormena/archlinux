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
  - `base-devel`,`bash-completion`,  `btrfs-progs`, `dosfstools`, `firefox`, `git`, `github-cli`, `man-db`, `man-pages`, `neovim`, `openssh`, `ripgrep`, `terminus-font`, `tmux`, `wireless-regdb`, `xclip`, `xdg-utils` e `xorg-xrandr`

> [!Note]
> Pacotes `base`, `linux`, `linux-firmware`, `efibootmgr`, `intel-ucode`, e adicionais de __Profile__ e __Applications__ já são instalados.

- __Timezone:__ `America/Sao_Paulo`
- __Automatic time sync (NTP):__ _não altere_
- __Install:__ _Confirme com `Yes`_

> [!Caution]
> Isso irá destruir o sistema de arquivos do dispositivo selecionado. Esteja certo desta ação.

  - Após a instalação, faça o _reboot_ e remova a mídia de instalação.

## Primeiro _boot_

### Reconectando o WiFi

Vamos fazer login na conta _root_ recém criada. Agora vamos configurar o `iwd` para reestabelecer a conexão com a Internet.
```
mkdir /etc/iwd

cat << EOF > /etc/iwd/main.conf
[General]
EnableNetworkConfiguration=true
Country=BR
EOF

systemctl enable --now iwd.service
systemctl enable --now systemd-resolved.service
```
Repita os passos em [Para redes abertas](#para-redes-abertas), [Para redes WPA-Personal](#para-redes-wpa-personal), ou [Para redes empresariais (WPA-Enterprise)](#para-redes-empresariais-wpa-enterprise) para conectar à algum SSID e então teste:
```
ping -c 3 google.com
```

### Ajustes de ambiente

Vamos ajustar algumas particularidades da conta _root_ para melhor gerenciar a instalação.
```
cat << EOF > ~/.bash_profile
# ~/.bash_profile

# Se existir, carregue ~/.bashrc
if [ -f ~/.bashrc ]; then
  source ~/.bashrc
fi
EOF

cat << EOF > ~/.bashrc
# ~/.bashrc

# Variáveis de ambiente
export EDITOR='/bin/nvim'

# Atalhos (aliases) úteis
alias ls='ls --color=always'
alias ll='ls -hl'
alias la='ls -A'
EOF

source ~/.bashrc

mkdir -p ~/.config/nvim
cat << EOF > ~/.config/nvim/init.lua
-- Ajustes de serviços desabilitados
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- Ajustes de usabilidade e legibilidade
vim.opt.number = true
vim.api.nvim_set_hl(0, "LineNr", { ctermfg = 7 })
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
EOF

cat << EOF > ~/.tmux.conf
set-option -g focus-events on
EOF
```

### Ajustes do systemd

```
systemctl set-default multi-user.target
systemctl isolate multi-user.target
```

### Ajuste de _sudoers_ para grupo _wheel_

Execute `visudo` e remova o comentário (`#`) da linha `%wheel ALL=(ALL:ALL) ALL`. Isso permite que usuários do grupo `wheel` possam executar comandos com privilégios elevados (da conta _root_) através do comando `sudo` e a senha de usuário.

### Ajustes de hardware

```
echo '650' > /sys/class/backlight/intel_backlight/brightness
echo '64' > /sys/class/leds/smc\:\:kbd_backlight/brightness
```

## Crie uma conta de usuário humano

Nós vamos usar o `systemd-homed` para criar um volume encriptado sob `/home`. Ao meu ver, essa abordagem possui vantagens sobre a encriptação total de disco. Desta forma, apenas os arquivos pessoais são encriptados e o desbloqueio do volume ocorre no ato de login, ao invés do _boot_.

Edite o arquivo `/etc/systemd/homed.conf`, de forma que contenha:
```
[Home]
DefaultStorage=luks
DefaultFileSystemType=btrfs
```

Também precisamos habilitar o serviço:
```
systemctl enable --now systemd-homed.service
```

Execute:
```
homectl create tormena \
  --real-name="Osmar Tormena Júnior" \
  --email-address=tormena@utfpr.edu.br \
  --location="Campo Mourão, PR, BR" \
  --birth-date=1986-03-06 \
  --member-of=wheel \
  --disk-size=20G \
  --luks-extra-mount-options="compress=zstd:3,noatime"
homectl activate tormena
```

Checando se a nova conta de usuário pertence ao grupo `wheel`:
```
id tormena
```

## Instalando uma interface gráfica

A
