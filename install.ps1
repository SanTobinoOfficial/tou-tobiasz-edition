# ToU Tobiasz Edition - Autoinstalator
# Uruchom prawym przyciskiem -> "Uruchom za pomoca programu PowerShell"

$ErrorActionPreference = "Stop"
$ProgressPreference    = "SilentlyContinue"

$REPO      = "SanTobinoOfficial/tou-tobiasz-edition"
$GAME_NAME = "Among Us - Tobiasz Edition"
$TOU_URL   = "https://github.com/AU-Avengers/TOU-Mira/releases/download/1.6.3/TouMirav1.6.3-x86-steam-itch.zip"
$API_URL   = "https://api.github.com/repos/$REPO/releases/latest"
$TMP       = "$env:TEMP\TouInstall"

# Plik z zapisana sciezka instalacji (czyta go update.ps1)
$CONFIG_DIR  = "$env:LOCALAPPDATA\TouTobiaszEdition"
$CONFIG_FILE = "$CONFIG_DIR\install_path.txt"

# Znane lokalizacje Among Us
$STEAM_DIR = "C:\Program Files (x86)\Steam\steamapps\common\Among Us"
$EPIC_DIRS = @(
    "C:\Program Files\Epic Games\Among Us",
    "C:\Program Files (x86)\Epic Games\Among Us",
    "$env:LOCALAPPDATA\..\LocalLow\Epic Games\Among Us"
)

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ToU Tobiasz Edition - Instalator" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# --- 0a. Wykryj lokalizacje Among Us ---
$steamOk = Test-Path "$STEAM_DIR\Among Us.exe"
$epicDir  = $EPIC_DIRS | Where-Object { Test-Path "$_\Among Us.exe" } | Select-Object -First 1
$epicOk   = $null -ne $epicDir

if (-not $steamOk -and -not $epicOk) {
    Write-Host "[BLAD] Nie znaleziono Among Us ani w Steam ani w Epic Games." -ForegroundColor Red
    Write-Host ""
    Write-Host "Sprawdzone sciezki Steam:" -ForegroundColor Yellow
    Write-Host "  $STEAM_DIR" -ForegroundColor DarkYellow
    Write-Host "Sprawdzone sciezki Epic:" -ForegroundColor Yellow
    $EPIC_DIRS | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkYellow }
    Write-Host ""
    Write-Host "Zainstaluj Among Us przez Steam lub Epic i sprobuj ponownie." -ForegroundColor Yellow
    Read-Host "Nacisnij Enter aby wyjsc"
    exit 1
}

# --- 0b. Wybor launchera (jesli oba) ---
$SOURCE_DIR = $null

if ($steamOk -and $epicOk) {
    Write-Host "Znaleziono Among Us w obu launcherach:" -ForegroundColor Cyan
    Write-Host "  [1] Steam - $STEAM_DIR" -ForegroundColor White
    Write-Host "  [2] Epic  - $epicDir" -ForegroundColor White
    Write-Host ""
    do { $choice = Read-Host "Ktora kopie skopiowac? (1/2)" }
    while ($choice -ne "1" -and $choice -ne "2")
    if ($choice -eq "1") { $SOURCE_DIR = $STEAM_DIR } else { $SOURCE_DIR = $epicDir }
}
elseif ($steamOk) {
    $SOURCE_DIR = $STEAM_DIR
    Write-Host "Znaleziono Among Us (Steam): $SOURCE_DIR" -ForegroundColor Green
}
else {
    $SOURCE_DIR = $epicDir
    Write-Host "Znaleziono Among Us (Epic): $SOURCE_DIR" -ForegroundColor Green
}

# --- 0c. Wybor folderu instalacji ---
Write-Host ""
$DESKTOP = [System.Environment]::GetFolderPath('Desktop')
Write-Host "Gdzie zainstalowac mod?" -ForegroundColor Cyan
Write-Host "  [1] C:\Games\$GAME_NAME  (domyslne)" -ForegroundColor White
Write-Host "  [2] Pulpit - $DESKTOP\$GAME_NAME" -ForegroundColor White
Write-Host "  [3] Inna lokalizacja (wpisz sam)" -ForegroundColor White
Write-Host ""

do { $destChoice = Read-Host "Wybor (1/2/3)" }
while ($destChoice -ne "1" -and $destChoice -ne "2" -and $destChoice -ne "3")

switch ($destChoice) {
    "1" { $INSTALL_DIR = "C:\Games\$GAME_NAME" }
    "2" { $INSTALL_DIR = "$DESKTOP\$GAME_NAME" }
    "3" {
        do {
            $customPath = Read-Host "Podaj pelna sciezke folderu (np. D:\Gry\AmongUsMod)"
            $customPath = $customPath.Trim().Trim('"')
        } while ([string]::IsNullOrWhiteSpace($customPath))
        $INSTALL_DIR = $customPath
    }
}

Write-Host ""
Write-Host "Folder instalacji: $INSTALL_DIR" -ForegroundColor Green
Write-Host ""

# Zapisz sciezke do konfigu (update.ps1 bedzie jej uzywac)
New-Item -ItemType Directory -Path $CONFIG_DIR -Force | Out-Null
Set-Content -Path $CONFIG_FILE -Value $INSTALL_DIR -Encoding UTF8

# 1 - Kopiuj Among Us
Write-Host "[1/5] Kopiowanie Among Us do: $INSTALL_DIR" -ForegroundColor Yellow
Write-Host "      (to moze zajac chwile...)"
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
    $latestVersion = "v1.0.2"
}

$pluginsDir = "$INSTALL_DIR\BepInEx\plugins"
New-Item -ItemType Directory -Path $pluginsDir -Force | Out-Null

$modUrl = "https://github.com/$REPO/releases/download/$latestVersion/TouTobiaszEdition.dll"
Invoke-WebRequest -Uri $modUrl -OutFile "$pluginsDir\TouTobiaszEdition.dll" -UseBasicParsing

Set-Content -Path "$INSTALL_DIR\tou_version.txt" -Value $latestVersion -Encoding UTF8
Write-Host "      OK ($latestVersion)" -ForegroundColor Green

# 4 - Zainstaluj auto-updater
Write-Host "[4/5] Konfigurowanie automatycznych aktualizacji..." -ForegroundColor Yellow
$updaterTarget = "$INSTALL_DIR\update.ps1"
$updaterUrl    = "https://github.com/$REPO/releases/download/$latestVersion/update.ps1"

try {
    Invoke-WebRequest -Uri $updaterUrl -OutFile $updaterTarget -UseBasicParsing
}
catch {
    $localUpdater = Join-Path (Split-Path $MyInvocation.MyCommand.Path) "update.ps1"
    if (Test-Path $localUpdater) { Copy-Item $localUpdater $updaterTarget -Force }
}

# Skrot "Sprawdz aktualizacje" w folderze gry
$checkBat = "$INSTALL_DIR\Sprawdz aktualizacje.bat"
Set-Content -Path $checkBat -Value "@echo off`r`npowershell.exe -ExecutionPolicy Bypass -WindowStyle Normal -File ""%~dp0update.ps1"" -Manual`r`n" -Encoding ASCII

if (Test-Path $updaterTarget) {
    $taskName = "ToU Tobiasz Edition Updater"
    $action   = New-ScheduledTaskAction `
        -Execute  "powershell.exe" `
        -Argument "-WindowStyle Hidden -NonInteractive -ExecutionPolicy Bypass -File `"$updaterTarget`""

    $trigger  = New-ScheduledTaskTrigger -AtLogon -User $env:USERNAME
    $settings = New-ScheduledTaskSettingsSet `
        -ExecutionTimeLimit (New-TimeSpan -Minutes 5) `
        -StartWhenAvailable $true `
        -MultipleInstances IgnoreNew

    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
    Register-ScheduledTask `
        -TaskName  $taskName `
        -Action    $action `
        -Trigger   $trigger `
        -Settings  $settings `
        -RunLevel  Limited `
        -Force | Out-Null

    Write-Host "      OK (zadanie: '$taskName')" -ForegroundColor Green
    Write-Host "      Reczna aktualizacja: 'Sprawdz aktualizacje.bat' w folderze gry" -ForegroundColor Green
}
else {
    Write-Host "      POMINIETO (brak update.ps1)" -ForegroundColor DarkYellow
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
Write-Host "Folder gry           : $INSTALL_DIR" -ForegroundColor White
Write-Host ""
Write-Host "Uruchom gre z:" -ForegroundColor White
Write-Host "  $INSTALL_DIR\Among Us.exe" -ForegroundColor Cyan
Write-Host ""
Write-Host "WAZNE: Uruchamiaj bezposrednio .exe, NIE przez Steam/Epic!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Auto-aktualizacje    : aktywne (Task Scheduler)" -ForegroundColor Green
Write-Host "Reczna aktualizacja  : 'Sprawdz aktualizacje.bat' w folderze gry" -ForegroundColor Green
Write-Host ""
Read-Host "Nacisnij Enter aby wyjsc"
