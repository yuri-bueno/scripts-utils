# Startup Scripts

Scripts para configurar rapidamente um ambiente de terminal ou VPS com **um único comando**.

---

# Linux VPS Setup

Configure uma VPS Linux automaticamente.

## Executar

```bash
bash <(curl -s https://raw.githubusercontent.com/yuri-bueno/scripts-utils/main/statup-vps.sh)
```

## O que o script faz

O script instala e configura automaticamente:

- Docker
- Git
- utilitários essenciais
- configuração básica de ambiente

## Requisitos

- VPS Linux
- Acesso SSH
- Permissão root

---

# Windows Terminal Setup

Configure automaticamente um terminal moderno no Windows com **Oh My Posh, Nerd Font e plugins úteis**.

## Executar

Abra o PowerShell e execute:

```powershell
irm https://raw.githubusercontent.com/yuri-bueno/scripts-utils/main/setup-ohmyposh.ps1 | iex
```

## O que será configurado

O script instala e configura automaticamente:

- Oh My Posh
- JetBrainsMono Nerd Font
- PowerShell plugins
- tema moderno do terminal
- configuração automática do Windows Terminal

## Plugins incluídos

### PSReadLine

Melhora a experiência do terminal com:

- autocomplete
- histórico avançado
- syntax highlighting

### posh-git

Mostra informações do Git diretamente no prompt:

- branch atual
- mudanças pendentes
- status do repositório

### eza

Adiciona ícones aos comandos de listagem de arquivos (`ls`).

### zoxide

Navegação inteligente entre diretórios baseada em frequência de uso.

Exe
