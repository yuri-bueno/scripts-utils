Write-Host "==================================" -ForegroundColor Cyan
Write-Host " Setup Oh My Posh Terminal" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# ------------------------------
# Preparar PowerShell Gallery
# ------------------------------
Write-Host "[0/7] Preparando PowerShell Gallery..." -ForegroundColor Yellow

try {
    Install-PackageProvider NuGet -Scope CurrentUser -Force -ErrorAction Stop | Out-Null
} catch {}

Set-PSRepository PSGallery -InstallationPolicy Trusted

# ------------------------------
# Atualizar PSReadLine
# ------------------------------
Write-Host ""
Write-Host "[1/7] Atualizando PSReadLine..." -ForegroundColor Yellow

Install-Module PSReadLine `
    -Scope CurrentUser `
    -Force `
    -SkipPublisherCheck `
    -AllowClobber

# ------------------------------
# Verificar Oh My Posh
# ------------------------------
Write-Host ""
Write-Host "[2/7] Verificando Oh My Posh..." -ForegroundColor Yellow

if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {

    Write-Host "Instalando Oh My Posh..." -ForegroundColor Green

    winget install JanDeDobbeleer.OhMyPosh `
        --accept-package-agreements `
        --accept-source-agreements
}
else {
    Write-Host "Oh My Posh ja instalado." -ForegroundColor Green
}

# ------------------------------
# Verificar Nerd Font
# ------------------------------
Write-Host ""
Write-Host "[3/7] Verificando JetBrainsMono Nerd Font..." -ForegroundColor Yellow

$fontInstalled = Get-ChildItem "C:\Windows\Fonts" | Where-Object { $_.Name -like "*JetBrainsMono*" }

if (-not $fontInstalled) {

    Write-Host "Instalando JetBrainsMono Nerd Font..." -ForegroundColor Green

    winget install DEVCOM.JetBrainsMonoNerdFont `
        --accept-package-agreements `
        --accept-source-agreements
}
else {
    Write-Host "JetBrainsMono Nerd Font ja instalada." -ForegroundColor Green
}

# ------------------------------
# Instalar plugins PowerShell
# ------------------------------
Write-Host ""
Write-Host "[4/7] Instalando plugins PowerShell..." -ForegroundColor Yellow

$plugins = @(
    "posh-git"
)

foreach ($plugin in $plugins) {

    if (-not (Get-Module -ListAvailable -Name $plugin)) {

        Write-Host "Instalando $plugin..." -ForegroundColor Green

        Install-Module $plugin `
            -Scope CurrentUser `
            -Repository PSGallery `
            -Force `
            -SkipPublisherCheck `
            -AllowClobber
    }
    else {
        Write-Host "$plugin ja instalado." -ForegroundColor Green
    }
}

# ------------------------------
# Instalar zoxide
# ------------------------------
Write-Host ""
Write-Host "[5/7] Verificando zoxide..." -ForegroundColor Yellow

if (-not (Get-Command zoxide -ErrorAction SilentlyContinue)) {

    Write-Host "Instalando zoxide..." -ForegroundColor Green

    winget install ajeetdsouza.zoxide `
        --accept-package-agreements `
        --accept-source-agreements
}
else {
    Write-Host "zoxide ja instalado." -ForegroundColor Green
}

# ------------------------------
# Instalar eza
# ------------------------------
Write-Host ""
Write-Host "[6/7] Verificando eza..." -ForegroundColor Yellow

if (-not (Get-Command eza -ErrorAction SilentlyContinue)) {

    Write-Host "Instalando eza..." -ForegroundColor Green

    winget install eza-community.eza `
        --accept-package-agreements `
        --accept-source-agreements
}
else {
    Write-Host "eza ja instalado." -ForegroundColor Green
}

# ------------------------------
# Configurar profile
# ------------------------------
Write-Host ""
Write-Host "[7/7] Configurando profile..." -ForegroundColor Yellow

$profilePath = "$HOME\Documents\PowerShell\profile.ps1"

$profileContent = @"
Import-Module PSReadLine

oh-my-posh init pwsh --config jandedobbeleer | Invoke-Expression

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# lazy load git
function git {
    Import-Module posh-git
    Remove-Item function:git
    git @args
}

# substituir ls padrão
if (Test-Path alias:ls) {
    Remove-Item alias:ls
}

function ls {
    & eza --icons --group-directories-first @args
}

function ll {
    & eza -la --icons --git --group-directories-first
}
"@

Set-Content $profilePath $profileContent

Write-Host "Profile configurado." -ForegroundColor Green

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Setup concluido!" -ForegroundColor Green
Write-Host "Reabra o terminal para aplicar as configuracoes." -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan