Write-Host "==================================" -ForegroundColor Cyan
Write-Host " Setup Oh My Posh Terminal" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# evitar prompts de instalação
Install-PackageProvider NuGet -Scope CurrentUser -Force | Out-Null
Set-PSRepository PSGallery -InstallationPolicy Trusted

# ------------------------------
# Atualizar PSReadLine
# ------------------------------
Write-Host "[0/6] Atualizando PSReadLine..." -ForegroundColor Yellow
Install-Module PSReadLine -Scope CurrentUser -Force -SkipPublisherCheck -AllowClobber

# ------------------------------
# Verificar Oh My Posh
# ------------------------------
Write-Host ""
Write-Host "[1/6] Verificando Oh My Posh..." -ForegroundColor Yellow

$ohmyposh = Get-Command oh-my-posh -ErrorAction SilentlyContinue

if (-not $ohmyposh) {
    Write-Host "Instalando Oh My Posh..." -ForegroundColor Green
    winget install JanDeDobbeleer.OhMyPosh --accept-package-agreements --accept-source-agreements
}
else {
    Write-Host "Oh My Posh ja instalado." -ForegroundColor Green
}

# ------------------------------
# Verificar Nerd Font
# ------------------------------
Write-Host ""
Write-Host "[2/6] Verificando JetBrainsMono Nerd Font..." -ForegroundColor Yellow

$fontInstalled = Get-ChildItem "C:\Windows\Fonts" | Where-Object { $_.Name -like "*JetBrainsMono*" }

if (-not $fontInstalled) {
    Write-Host "Instalando JetBrainsMono Nerd Font..." -ForegroundColor Green
    winget install DEVCOM.JetBrainsMonoNerdFont --accept-package-agreements --accept-source-agreements
}
else {
    Write-Host "JetBrainsMono Nerd Font ja instalada." -ForegroundColor Green
}

# ------------------------------
# Instalar plugins
# ------------------------------
Write-Host ""
Write-Host "[3/6] Instalando plugins PowerShell..." -ForegroundColor Yellow

$plugins = @(
    "Terminal-Icons",
    "posh-git"
)

foreach ($plugin in $plugins) {

    $installed = Get-Module -ListAvailable -Name $plugin

    if (-not $installed) {
        Write-Host "Instalando $plugin..." -ForegroundColor Green
        Install-Module $plugin -Scope CurrentUser -Force -SkipPublisherCheck -AllowClobber
    }
    else {
        Write-Host "$plugin ja instalado." -ForegroundColor Green
    }
}

# ------------------------------
# Instalar zoxide
# ------------------------------
Write-Host ""
Write-Host "[4/6] Instalando zoxide..." -ForegroundColor Yellow

$zoxide = Get-Command zoxide -ErrorAction SilentlyContinue

if (-not $zoxide) {
    winget install ajeetdsouza.zoxide --accept-package-agreements --accept-source-agreements
}

# ------------------------------
# Configurar profile universal
# ------------------------------
Write-Host ""
Write-Host "[5/6] Configurando profile..." -ForegroundColor Yellow

$profilePath = "$HOME\Documents\PowerShell\profile.ps1"

if (!(Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

$profileContent = Get-Content $profilePath -ErrorAction SilentlyContinue

$lines = @(
'Import-Module PSReadLine',
'oh-my-posh init pwsh --config jandedobbeleer | Invoke-Expression',
'Invoke-Expression (& { (zoxide init powershell | Out-String) })',

'# lazy load posh-git',
'function git {',
'    Import-Module posh-git',
'    Remove-Item function:git',
'    git @args',
'}',

'# lazy load terminal-icons',
'function ls {',
'    Import-Module Terminal-Icons',
'    Remove-Item function:ls',
'    ls @args',
'}'
)

foreach ($line in $lines) {
    if ($profileContent -notcontains $line) {
        Add-Content $profilePath $line
    }
}

Write-Host "Profile configurado." -ForegroundColor Green

# ------------------------------
# Configurar fonte Windows Terminal
# ------------------------------
Write-Host ""
Write-Host "[6/6] Configurando fonte do Windows Terminal..." -ForegroundColor Yellow

$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

if (Test-Path $settingsPath) {

    $json = Get-Content $settingsPath -Raw | ConvertFrom-Json

    if (-not $json.profiles.defaults) {
        $json.profiles | Add-Member -Name defaults -MemberType NoteProperty -Value @{}
    }

    if (-not $json.profiles.defaults.font) {
        $json.profiles.defaults | Add-Member -Name font -MemberType NoteProperty -Value @{}
    }

    $json.profiles.defaults.font.face = "JetBrainsMono Nerd Font"

    $json | ConvertTo-Json -Depth 10 | Set-Content $settingsPath

    Write-Host "Fonte configurada no Windows Terminal." -ForegroundColor Green
}
else {
    Write-Host "Windows Terminal nao encontrado." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Setup concluido!" -ForegroundColor Green
Write-Host "Reabra o terminal para aplicar as configuracoes." -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan