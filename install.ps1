# ToU Tobiasz Edition - Autoinstalator
# Uruchom prawym przyciskiem -> "Uruchom za pomoca programu PowerShell"

$ErrorActionPreference = "Stop"
$ProgressPreference    = "SilentlyContinue"

$REPO        = "SanTobinoOfficial/tou-tobiasz-edition"
$GAME_NAME   = "Among Us - Tobiasz Edition"
$INSTALL_DIR = "C:\Games\$GAME_NAME"
$STEAM_DIR   = "C:\Program Files (x86)\Steam\steamapps\common\Among Us"
$TOU_URL     = "https://github.com/AU-Avengers/TOU-Mira/releases/download/1.6.3/TouMirav1.6.3-x86-steam-itch.zip"
$API_URL     = "https://api.github.com/repos/$REPO/releases/latest"
$TMP         = "$env:TEMP\TouInstall"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ToU Tobiasz Edition - Instalator" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Sprawdz Among Us w Steam
if (-not (Test-Path "$STEAM_DIR\Among Us.exe")) {
    Write-Host "[BLAD] Nie znaleziono Among Us w:" -ForegroundColor Red
    Write-Host "  $STEAM_DIR" -ForegroundColor Yellow
    Write-Host "Upewnij sie ze Among Us jest zainstalowane przez Steam." -ForegroundColor Yellow
    Read-Host "Nacisnij Enter aby wyjsc"
    exit 1
}

# 1 - Kopiuj Among Us
Write-Host "[1/5] Kopiowanie Among Us do: $INSTALL_DIR" -ForegroundColor Yellow
Write-Host "      (to moze zajac chwile...)"
New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null
Copy-Item "$STEAM_DIR\*" $INSTALL_DIR -Recurse -Force
Write-Host "      OK" -ForegroundColor Green

# 2 - Pobierz i zainstaluj TOU:Mira
Write-Host "[2/5] Pobieranie Town of Us: Mira 1.6.3..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $TMP -Force | Out-Null
$zipPath     = "$TMP\toumira.zip"
$extractPath = "$TMP\toumira"
Invoke-WebRequest -Uri $TOU_URL -OutFile $zipPath -UseBasicParsing
Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
$src = (Get-ChildItem $extractPath -Directory | Select-Object -First 1).FullName
Copy-Item "$src\*" $INSTALL_DIR -Recurse -Force
Write-Host "      OK" -ForegroundColor Green

# 3 - Pobierz mod i wersje z GitHub
Write-Host "[3/5] Pobieranie ToU Tobiasz Edition..." -ForegroundColor Yellow
try {
    $release       = Invoke-RestMethod -Uri $API_URL -UseBasicParsing -Headers @{ "User-Agent" = "TouTobiaszInstaller/1.0" }
    $latestVersion = $release.tag_name.Trim()
}
catch {
    $latestVersion = "v1.0.0"
}

$pluginsDir = "$INSTALL_DIR\BepInEx\plugins"
New-Item -ItemType Directory -Path $pluginsDir -Force | Out-Null

$modUrl = "https://github.com/$REPO/releases/download/$latestVersion/TouTobiaszEdition.dll"
Invoke-WebRequest -Uri $modUrl -OutFile "$pluginsDir\TouTobiaszEdition.dll" -UseBasicParsing

# Zapisz zainstalowana wersje
Set-Content -Path "$INSTALL_DIR\tou_version.txt" -Value $latestVersion -Encoding UTF8
Write-Host "      OK ($latestVersion)" -ForegroundColor Green

# 4 - Zainstaluj auto-updater
Write-Host "[4/5] Konfigurowanie automatycznych aktualizacji..." -ForegroundColor Yellow
$updaterUrl    = "https://github.com/$REPO/releases/download/$latestVersion/update.ps1"
$updaterTarget = "$INSTALL_DIR\update.ps1"

try {
    Invoke-WebRequest -Uri $updaterUrl -OutFile $updaterTarget -UseBasicParsing
}
catch {
    # Fallback - skopiuj z tego samego folderu co install.ps1 (instalacja deweloperska)
    $localUpdater = Join-Path (Split-Path $MyInvocation.MyCommand.Path) "update.ps1"
    if (Test-Path $localUpdater) {
        Copy-Item $localUpdater $updaterTarget -Force
    }
}

if (Test-Path $updaterTarget) {
    $taskName = "ToU Tobiasz Edition Updater"
    $action   = New-ScheduledTaskAction `
        -Execute  "powershell.exe" `
        -Argument "-WindowStyle Hidden -NonInteractive -ExecutionPolicy Bypass -File `"$updaterTarget`""

    # Uruchom 30 sekund po zalogowaniu (zeby nie spowalnialo startu)
    $trigger  = New-ScheduledTaskTrigger -AtLogon -User $env:USERNAME
    $settings = New-ScheduledTaskSettingsSet `
        -ExecutionTimeLimit (New-TimeSpan -Minutes 5) `
        -StartWhenAvailable $true `
        -MultipleInstances IgnoreNew

    # Podmien jesli juz istnieje
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
    Register-ScheduledTask `
        -TaskName  $taskName `
        -Action    $action `
        -Trigger   $trigger `
        -Settings  $settings `
        -RunLevel  Limited `
        -Force | Out-Null

    Write-Host "      OK (zadanie: '$taskName')" -ForegroundColor Green
}
else {
    Write-Host "      POMINIĘTO (brak update.ps1)" -ForegroundColor DarkYellow
}

# 5 - Sprzatanie
Write-Host "[5/5] Czyszczenie plikow tymczasowych..." -ForegroundColor Yellow
Remove-Item $TMP -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "      OK" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Instalacja zakonczona!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Zainstalowana wersja : $latestVersion" -ForegroundColor White
Write-Host ""
Write-Host "Uruchom gre z:" -ForegroundColor White
Write-Host "  $INSTALL_DIR\Among Us.exe" -ForegroundColor Cyan
Write-Host ""
Write-Host "WAZNE: Uruchamiaj bezposrednio .exe, NIE przez Steam!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Auto-aktualizacje: aktywne (Task Scheduler)" -ForegroundColor Green
Write-Host ""
Read-Host "Nacisnij Enter aby wyjsc"
