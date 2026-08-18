# Instalação do ArchLinux em um MacBook Pro 13" (Early 2015)

Neste repositório, estou documentando a instalação baseada na Live ISO de 2026-08-01, embora deva funcionar com qualquer versão.

Boot com a live ISO

## Ajustando o layout do teclado e fonte do console

Para o _layout_ de teclado operar naturalmente com acentos, til e cedilha, é necessário configurar o `loadkeys` adequadamente. O diretório `/usr/share/kbd/keymaps` contém todos os _layouts_ disponíveis.

Usando uma fonte da família Terminus. O diretório `/usr/share/kbd/consolefonts`, contém as fontes. Boas opções: `ter-114b`, `ter-116b`, `ter-118b`, `ter-120b`, `ter-122b`, `ter-124b`, `ter-128b`, ou `ter-132b`.

```
# loadkeys br-latin1-us
# setfont ter-132b
```

## Conecte-se à Internet

Uma conexão cabeada deve ser reconhecida automaticamente.

Para garantir o funcionamento do WiFi nas bandas de 5 GHz é necessário respeitar a canalização e os limites de potência nacionais. O pacote `wireless-regdb` provê essas informações. Executando
```
# iw reg set BR
```
garante a visibilidade das bandas além de 2,4 GHz.

Vamos averiguar o nome do dispositivo de rede. Executando
```
# iwctl device list
```
é retornado uma lista de dispositivos de rede, provavelmente com um único item. Neste caso `wlan0`. Agora, executando
```
# iwctl station wlan0 scan
# iwctl station wlan0 get-networks
```
deve resultar em uma lista de redes sem fio ao alcance.

### Para redes abertas

Para se conectar a uma rede aberta, basta executar
```
# iwctl station wlan0 connect SSID
```
Um arquivo `/var/lib/iwd/SSID.open` é criado com a configuração desta rede.

### Para redes WPA-Personal

Para se conectar, execute:
```
# iwctl --passphrase=PASSPHRASE station wlan0 connect SSID
```
Um arquivo `/var/lib/iwd/SSID.psk` é criado com a configuração desta rede.

### Para redes empresariais (WPA-Enterprise)

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
# iwctl station wlan0 connect SSID
```
para se conectar à rede.

### Testando a conectividade

```
# ping -c 3 google.com
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
# efibootmgr -b 0000 -B
# efibootmgr -b 0001 -B
```

### Executando o script automático de instalação

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
* O pacote `gnuplot` é utilizado em meu fluxo de trabalho com o TeX Live.
* Finalmente, algumas ferramentas de conveniência: `tmux` é muito útil para trabalhar no console; `bash-completion` ajuda a evitar a síndrome de tunel do carpo.

Agora basta executar o _script_ `install.sh`.

Para evitar a reinserção das credenciais de rede, novamente, após o primeiro _boot_ do sistema, podemos copiar os arquivos `.open`, `.psk`, ou `.8021x` da live ISO para o novo sistema.
```
# mkdir /mnt/var/lib/iwd
# cp /var/lib/iwd/SSID{.open,.psk,.8021x} /mnt/var/lib/iwd/
```

Os passos finais da configuração são feitos através de um 'chroot'. O _script_ `archroot.sh` deve ser executado dentro deste ambiente.
```
cp archroot.sh /mnt/root/
#arch-chroot -S /mnt
```

### Senha de 'root'

Vamos agora criar uma senha do usuário __root__ neste sistema (não se esqueça desta senha):
```
# passwd
```

### Checando a sanidade da instalação

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

## Primeiro boot do sistema e configurações adicionais

Os comandos desta seção são executados no sistema recém instalado. A maioria dos comandos são executados como __root__. Os passos estão contidos em [FirstBoot.md](firstboot.md).
