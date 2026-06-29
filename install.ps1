# ToU Tobiasz Edition - Autoinstalator
# Uruchom prawym przyciskiem -> "Uruchom za pomocą programu PowerShell"

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$GAME_NAME  = "Among Us - Tobiasz Edition"
$INSTALL_DIR = "C:\Games\$GAME_NAME"
$STEAM_DIR   = "C:\Program Files (x86)\Steam\steamapps\common\Among Us"
$TOU_URL     = "https://github.com/AU-Avengers/TOU-Mira/releases/download/1.6.3/TouMirav1.6.3-x86-steam-itch.zip"
$MOD_URL     = "https://github.com/SanTobinoOfficial/tou-tobiasz-edition/releases/latest/download/TouTobiaszEdition.dll"
$TMP         = "$env:TEMP\TouInstall"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ToU Tobiasz Edition - Instalator" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Sprawdz Steam
if (-not (Test-Path "$STEAM_DIR\Among Us.exe")) {
    Write-Host "[BLAD] Nie znaleziono Among Us w: $STEAM_DIR" -ForegroundColor Red
    Write-Host "Upewnij sie ze Among Us jest zainstalowane przez Steam." -ForegroundColor Yellow
    Read-Host "Nacisnij Enter aby wyjsc"
    exit 1
}

# Stworz folder instalacji
Write-Host "[1/4] Kopiowanie Among Us do: $INSTALL_DIR" -ForegroundColor Yellow
Write-Host "      (to moze zajac chwile...)"
New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null
Copy-Item "$STEAM_DIR\*" $INSTALL_DIR -Recurse -Force
Write-Host "      OK" -ForegroundColor Green

# Pobierz i zainstaluj TOU:Mira
Write-Host "[2/4] Pobieranie Town of Us: Mira 1.6.3..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $TMP -Force | Out-Null
$zipPath = "$TMP\toumira.zip"
Invoke-WebRequest -Uri $TOU_URL -OutFile $zipPath -UseBasicParsing
$extractPath = "$TMP\toumira"
Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
$src = (Get-ChildItem $extractPath -Directory | Select-Object -First 1).FullName
Copy-Item "$src\*" $INSTALL_DIR -Recurse -Force
Write-Host "      OK" -ForegroundColor Green

# Pobierz nasz mod
Write-Host "[3/4] Pobieranie ToU Tobiasz Edition..." -ForegroundColor Yellow
$pluginsDir = "$INSTALL_DIR\BepInEx\plugins"
New-Item -ItemType Directory -Path $pluginsDir -Force | Out-Null
Invoke-WebRequest -Uri $MOD_URL -OutFile "$pluginsDir\TouTobiaszEdition.dll" -UseBasicParsing
Write-Host "      OK" -ForegroundColor Green

# Sprz?tanie
Write-Host "[4/4] Czyszczenie plikow tymczasowych..." -ForegroundColor Yellow
Remove-Item $TMP -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "      OK" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Instalacja zakonczona!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Uruchom gre z:" -ForegroundColor White
Write-Host "  $INSTALL_DIR\Among Us.exe" -ForegroundColor Cyan
Write-Host ""
Write-Host "WAZNE: Uruchamiaj bezposrednio .exe, NIE przez Steam!" -ForegroundColor Yellow
Write-Host ""
Read-Host "Nacisnij Enter aby wyjsc"
