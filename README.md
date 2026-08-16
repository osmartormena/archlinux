# Instalação passo-a-passo do ArchLinux em um MacBook Pro 13" (Early 2015)

Neste repositório, estou documentando a instalação baseada na Live ISO de 2026-08-01, embora deva funcionar com qualquer versão.

A ordem das operações segue a documentação de instalação <https://wiki.archlinux.org/title/Installation_guide>. Desvios dos _defaults_ foram necessários para melhor ajustar à plataforma (macbookpro12,1) e foram estritamente suportados pela documentação. Por se tratar de uma distro do tipo _rolling release_, alguns detalhes podem ser modificados sem muito aviso prévio.

Todas as modificações para ajuste em um MacBook Pro (MBP) estão claramente marcadas. O passo-a-passo deve servir, com poucas adaptações, para qualquer _desktop_ ou _laptop_ relativamente contemporâneo (64-bit CPU + UEFI + SSD).

Na instalação, a totalidade dos comandos são executados como usuário __root__. Para deixar isso claro, todos os _prompts_ são indicados por
```
#
```
em alguns passos finais da configuração da conta de usuário (humano), os comandos devem ser executados pela conta de usuário (neste exemplo, __tormena__). Nesse caso, os _prompts_ são indicados por
```
$
```

## Instalando o sistema através da live ISO

Nesta seção, todos os comandos são executados como __root__, através do _boot_ na live ISO. O passo-a-passo está contido em [Install.md](install.md).

## Primeiro _boot_ do sistema e configurações adicionais

Os comandos desta seção são executados no sistema recém instalado. A maioria dos comandos são executados como __root__. Os passos estão contidos em [FirstBoot.md](firstboot.md).
