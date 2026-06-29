# ToU Tobiasz Edition - Autoinstalator
# Normalnie: pytania o launcher i folder
# Silent:    zero pytan, domyslne opcje (uzyj z Zainstaluj.bat)

param([switch]$Silent)

$ErrorActionPreference = "Stop"
$ProgressPreference    = "SilentlyContinue"

$REPO      = "SanTobinoOfficial/tou-tobiasz-edition"
$GAME_NAME = "Among Us - Tobiasz Edition"
$TOU_URL   = "https://github.com/AU-Avengers/TOU-Mira/releases/download/1.6.3/TouMirav1.6.3-x86-steam-itch.zip"
$API_URL   = "https://api.github.com/repos/$REPO/releases/latest"
$TMP       = "$env:TEMP\TouInstall_$(Get-Random)"
$CONFIG_DIR  = "$env:LOCALAPPDATA\TouTobiaszEdition"
$CONFIG_FILE = "$CONFIG_DIR\install_path.txt"

$STEAM_DIR = "C:\Program Files (x86)\Steam\steamapps\common\Among Us"
$EPIC_DIRS = @(
    "C:\Program Files\Epic Games\Among Us",
    "C:\Program Files (x86)\Epic Games\Among Us"
)

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ToU Tobiasz Edition - Instalator" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# --- Wykryj Among Us ---
$steamOk = Test-Path "$STEAM_DIR\Among Us.exe"
$epicDir  = $EPIC_DIRS | Where-Object { Test-Path "$_\Among Us.exe" } | Select-Object -First 1
$epicOk   = $null -ne $epicDir

if (-not $steamOk -and -not $epicOk) {
    Write-Host "[BLAD] Nie znaleziono Among Us ani w Steam ani w Epic Games." -ForegroundColor Red
    Write-Host "Zainstaluj Among Us przez Steam lub Epic i sprobuj ponownie." -ForegroundColor Yellow
    if (-not $Silent) { Read-Host "Nacisnij Enter aby wyjsc" }
    exit 1
}

# --- Wybor launchera ---
$SOURCE_DIR = $null
if ($steamOk -and $epicOk -and -not $Silent) {
    Write-Host "Znaleziono Among Us w obu launcherach:" -ForegroundColor Cyan
    Write-Host "  [1] Steam - $STEAM_DIR" -ForegroundColor White
    Write-Host "  [2] Epic  - $epicDir" -ForegroundColor White
    Write-Host ""
    do { $choice = Read-Host "Ktora kopie skopiowac? (1/2)" }
    while ($choice -ne "1" -and $choice -ne "2")
    $SOURCE_DIR = if ($choice -eq "1") { $STEAM_DIR } else { $epicDir }
}
elseif ($steamOk) {
    $SOURCE_DIR = $STEAM_DIR
    Write-Host "Znaleziono Among Us (Steam)" -ForegroundColor Green
}
else {
    $SOURCE_DIR = $epicDir
    Write-Host "Znaleziono Among Us (Epic)" -ForegroundColor Green
}

# --- Wybor folderu instalacji ---
$DESKTOP = [System.Environment]::GetFolderPath('Desktop')
$INSTALL_DIR = "C:\Games\$GAME_NAME"

if (-not $Silent) {
    Write-Host ""
    Write-Host "Gdzie zainstalowac mod?" -ForegroundColor Cyan
    Write-Host "  [1] C:\Games\$GAME_NAME  (domyslne - ENTER)" -ForegroundColor White
    Write-Host "  [2] Pulpit" -ForegroundColor White
    Write-Host "  [3] Inna lokalizacja" -ForegroundColor White
    Write-Host ""
    $destChoice = Read-Host "Wybor (1/2/3 lub ENTER = domyslne)"
    if ($destChoice -eq "2") { $INSTALL_DIR = "$DESKTOP\$GAME_NAME" }
    elseif ($destChoice -eq "3") {
        do { $customPath = (Read-Host "Podaj sciezke").Trim().Trim('"') }
        while ([string]::IsNullOrWhiteSpace($customPath))
        $INSTALL_DIR = $customPath
    }
}

Write-Host ""
Write-Host "Folder instalacji: $INSTALL_DIR" -ForegroundColor Green
Write-Host ""

New-Item -ItemType Directory -Path $CONFIG_DIR -Force | Out-Null
Set-Content -Path $CONFIG_FILE -Value $INSTALL_DIR -Encoding UTF8

# 1 - Kopiuj Among Us
Write-Host "[1/5] Kopiowanie Among Us..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null
Copy-Item "$SOURCE_DIR\*" $INSTALL_DIR -Recurse -Force
Write-Host "      OK" -ForegroundColor Green

# 2 - Pobierz i zainstaluj TOU:Mira
Write-Host "[2/5] Pobieranie Town of Us: Mira 1.6.3..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $TMP -Force | Out-Null
$zipPath     = "$TMP\toumira.zip"
$extractPath = "$TMP\toumira"
Invoke-WebRequest -Uri $TOU_URL -OutFile $zipPath -UseBasicParsing
Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

# Kopiuj z podfolderu jesli istnieje, albo bezposrednio z folderu ekstrakcji
$subDir = Get-ChildItem $extractPath -Directory | Select-Object -First 1
$src    = if ($null -ne $subDir) { $subDir.FullName } else { $extractPath }
Copy-Item "$src\*" $INSTALL_DIR -Recurse -Force
Write-Host "      OK" -ForegroundColor Green

# 3 - Pobierz mod DLL
Write-Host "[3/5] Pobieranie ToU Tobiasz Edition..." -ForegroundColor Yellow
try {
    $release       = Invoke-RestMethod -Uri $API_URL -UseBasicParsing -Headers @{ "User-Agent" = "TouTobiaszInstaller/1.0" }
    $latestVersion = $release.tag_name.Trim()
} catch {
    $latestVersion = "v1.0.4"
}

$pluginsDir = "$INSTALL_DIR\BepInEx\plugins"
New-Item -ItemType Directory -Path $pluginsDir -Force | Out-Null
$modUrl = "https://github.com/$REPO/releases/download/$latestVersion/TouTobiaszEdition.dll"
Invoke-WebRequest -Uri $modUrl -OutFile "$pluginsDir\TouTobiaszEdition.dll" -UseBasicParsing
Set-Content -Path "$INSTALL_DIR\tou_version.txt" -Value $latestVersion -Encoding UTF8
Write-Host "      OK ($latestVersion)" -ForegroundColor Green

# 4 - Auto-updater
Write-Host "[4/5] Konfigurowanie automatycznych aktualizacji..." -ForegroundColor Yellow
$updaterTarget = "$INSTALL_DIR\update.ps1"
$updaterUrl    = "https://github.com/$REPO/releases/download/$latestVersion/update.ps1"
try {
    Invoke-WebRequest -Uri $updaterUrl -OutFile $updaterTarget -UseBasicParsing
} catch {
    $localUpdater = Join-Path (Split-Path $MyInvocation.MyCommand.Path) "update.ps1"
    if (Test-Path $localUpdater) { Copy-Item $localUpdater $updaterTarget -Force }
}

$checkBat = "$INSTALL_DIR\Sprawdz aktualizacje.bat"
Set-Content -Path $checkBat -Value "@echo off`r`npowershell.exe -ExecutionPolicy Bypass -WindowStyle Normal -File ""%~dp0update.ps1"" -Manual`r`n" -Encoding ASCII

if (Test-Path $updaterTarget) {
    $taskName = "ToU Tobiasz Edition Updater"
    $action   = New-ScheduledTaskAction -Execute "powershell.exe" `
        -Argument "-WindowStyle Hidden -NonInteractive -ExecutionPolicy Bypass -File `"$updaterTarget`""
    $trigger  = New-ScheduledTaskTrigger -AtLogon -User $env:USERNAME
    $settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 5) `
        -StartWhenAvailable -MultipleInstances IgnoreNew
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger `
        -Settings $settings -RunLevel Limited -Force | Out-Null
    Write-Host "      OK" -ForegroundColor Green
}

# 5 - Sprzatanie
Write-Host "[5/5] Czyszczenie..." -ForegroundColor Yellow
Remove-Item $TMP -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "      OK" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Instalacja zakonczona!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Wersja     : $latestVersion" -ForegroundColor White
Write-Host "Gra        : $INSTALL_DIR\Among Us.exe" -ForegroundColor Cyan
Write-Host ""
Write-Host "WAZNE: Uruchamiaj bezposrednio .exe, NIE przez Steam/Epic!" -ForegroundColor Yellow
Write-Host ""
if (-not $Silent) { Read-Host "Nacisnij Enter aby wyjsc" }
