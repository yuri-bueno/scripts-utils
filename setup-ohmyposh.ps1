Write-Host "==================================" -ForegroundColor Cyan
Write-Host " Setup Oh My Posh Terminal" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# ------------------------------
# Preparar PowerShell Gallery
# ------------------------------
Write-Host "[1/6] Preparando PowerShell Gallery..." -ForegroundColor Yellow

try {
    Install-PackageProvider NuGet -Scope CurrentUser -Force -ErrorAction Stop | Out-Null
} catch {}

Set-PSRepository PSGallery -InstallationPolicy Trusted

# ------------------------------
# Atualizar PSReadLine
# ------------------------------
Write-Host ""
Write-Host "[2/6] Atualizando PSReadLine..." -ForegroundColor Yellow

Install-Module PSReadLine `
    -Scope CurrentUser `
    -Force `
    -SkipPublisherCheck `
    -AllowClobber

# ------------------------------
# Oh My Posh
# ------------------------------
Write-Host ""
Write-Host "[3/6] Verificando Oh My Posh..." -ForegroundColor Yellow

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
# Nerd Font
# ------------------------------
Write-Host ""
Write-Host "[4/6] Verificando JetBrainsMono Nerd Font..." -ForegroundColor Yellow

$fontInstalled = Get-ChildItem "C:\Windows\Fonts" | Where-Object { $_.Name -like "*JetBrainsMono*" }

if (-not $fontInstalled) {

    Write-Host "Instalando JetBrainsMono Nerd Font..." -ForegroundColor Green

    winget install DEVCOM.JetBrainsMonoNerdFont `
        --accept-package-agreements `
        --accept-source-agreements
}

# ------------------------------
# Instalar ferramentas
# ------------------------------
Write-Host ""
Write-Host "[5/6] Verificando ferramentas..." -ForegroundColor Yellow

$tools = @{
    "zoxide" = "ajeetdsouza.zoxide"
    "eza"    = "eza-community.eza"
}

foreach ($tool in $tools.Keys) {

    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {

        Write-Host "Instalando $tool..." -ForegroundColor Green

        winget install $tools[$tool] `
            --accept-package-agreements `
            --accept-source-agreements
    }
}

# ------------------------------
# Criar profile compartilhado
# ------------------------------
Write-Host ""
Write-Host "[6/6] Configurando profiles..." -ForegroundColor Yellow

$sharedProfile = "$HOME\Documents\PowerShell\terminal-profile.ps1"

$profileContent = @'
Import-Module PSReadLine

# cache do oh-my-posh
$ompCache = "$env:LOCALAPPDATA\ohmyposh-init.ps1"

if (!(Test-Path $ompCache)) {
    oh-my-posh init pwsh --config jandedobbeleer > $ompCache
}

. $ompCache

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
'@

Set-Content $sharedProfile $profileContent

# profiles que vão importar o compartilhado
$profiles = @(
    "$HOME\Documents\PowerShell\profile.ps1",
    "$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
)

foreach ($profile in $profiles) {

    $dir = Split-Path $profile

    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    Set-Content $profile ". `"$sharedProfile`""
}

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Setup concluido!" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Cyan