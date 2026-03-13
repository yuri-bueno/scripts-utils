Write-Host "==================================" -ForegroundColor Cyan
Write-Host " Setup Oh My Posh Terminal" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# ------------------------------
# Verificar Oh My Posh
# ------------------------------
Write-Host "[1/3] Verificando Oh My Posh..." -ForegroundColor Yellow

$ohmyposh = winget list JanDeDobbeleer.OhMyPosh 2>$null

if (-not $ohmyposh) {
    Write-Host "Instalando Oh My Posh..." -ForegroundColor Green
    winget install JanDeDobbeleer.OhMyPosh --source winget --accept-package-agreements --accept-source-agreements
}
else {
    Write-Host "Oh My Posh ja instalado." -ForegroundColor Green
}

# ------------------------------
# Instalar Nerd Font
# ------------------------------
Write-Host ""
Write-Host "[2/3] Instalando JetBrainsMono Nerd Font..." -ForegroundColor Yellow

$font = winget list DEVCOM.JetBrainsMonoNerdFont 2>$null

if (-not $font) {
    Write-Host "Instalando fonte..." -ForegroundColor Green
    winget install DEVCOM.JetBrainsMonoNerdFont --accept-package-agreements --accept-source-agreements
}
else {
    Write-Host "JetBrainsMono Nerd Font ja instalada." -ForegroundColor Green
}

# ------------------------------
# Configurar tema
# ------------------------------
Write-Host ""
Write-Host "[3/3] Configurando tema jandedobbeleer..." -ForegroundColor Yellow

if (!(Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

$line = 'oh-my-posh init pwsh --config jandedobbeleer | Invoke-Expression'

if (-not (Select-String -Path $PROFILE -Pattern "oh-my-posh init pwsh" -Quiet)) {
    Add-Content -Path $PROFILE -Value $line
}

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Setup concluido!" -ForegroundColor Green
Write-Host "Feche e abra o terminal." -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan