# ToU Tobiasz Edition - Auto-Updater
# Uruchamiany automatycznie przez Windows Task Scheduler przy logowaniu.
# Reczne uruchomienie: "Sprawdz aktualizacje.bat" w folderze gry.

param([switch]$Manual)

$ErrorActionPreference = "SilentlyContinue"
$ProgressPreference    = "SilentlyContinue"

$REPO        = "SanTobinoOfficial/tou-tobiasz-edition"
$DLL_NAME    = "TouTobiaszEdition.dll"
$API_URL     = "https://api.github.com/repos/$REPO/releases/latest"
$CONFIG_FILE = "$env:LOCALAPPDATA\TouTobiaszEdition\install_path.txt"

# Ustal sciezke instalacji: plik konfigu -> fallback hardcoded
$INSTALL_DIR = "C:\Games\Among Us - Tobiasz Edition"
if (Test-Path $CONFIG_FILE) {
    $saved = (Get-Content $CONFIG_FILE -Raw -ErrorAction SilentlyContinue).Trim()
    if (-not [string]::IsNullOrWhiteSpace($saved)) { $INSTALL_DIR = $saved }
}

$VERSION_FILE = "$INSTALL_DIR\tou_version.txt"
$PLUGINS_DIR  = "$INSTALL_DIR\BepInEx\plugins"

function Write-Status {
    param([string]$Msg, [string]$Color = "White")
    if ($Manual) { Write-Host $Msg -ForegroundColor $Color }
}

function Show-Toast {
    param([string]$Title, [string]$Body)
    try {
        Add-Type -AssemblyName Windows.Data | Out-Null
        Add-Type -AssemblyName Windows.UI   | Out-Null
        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
        [Windows.Data.Xml.Dom.XmlDocument,                  Windows.Data.Xml.Dom,     ContentType = WindowsRuntime] | Out-Null

        $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
        $xml.LoadXml(@"
<toast activationType="protocol">
  <visual>
    <binding template="ToastGeneric">
      <text>$Title</text>
      <text>$Body</text>
    </binding>
  </visual>
</toast>
"@)
        $toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
        [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("ToU Tobiasz Edition").Show($toast)
    }
    catch { }
}

if ($Manual) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  ToU Tobiasz Edition - Sprawdz aktualizacje" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
}

# Sprawdz czy mod jest zainstalowany
if (-not (Test-Path "$INSTALL_DIR\Among Us.exe")) {
    Write-Status "[BLAD] Nie znaleziono instalacji w: $INSTALL_DIR" "Red"
    if ($Manual) { Read-Host "Nacisnij Enter aby wyjsc" }
    exit 0
}

# Zaladuj aktualnie zainstalowana wersje
$currentVersion = "v0.0.0"
if (Test-Path $VERSION_FILE) {
    $currentVersion = (Get-Content $VERSION_FILE -Raw -ErrorAction SilentlyContinue).Trim()
}

Write-Status "Zainstalowana wersja : $currentVersion" "White"
Write-Status "Sprawdzam GitHub..." "Yellow"

try {
    $release = Invoke-RestMethod `
        -Uri $API_URL `
        -UseBasicParsing `
        -Headers @{ "User-Agent" = "TouTobiaszEdition-Updater/1.0" }

    $latestVersion = $release.tag_name.Trim()
    if ([string]::IsNullOrEmpty($latestVersion)) {
        Write-Status "[BLAD] Nie udalo sie pobrac informacji o wersji." "Red"
        if ($Manual) { Read-Host "Nacisnij Enter aby wyjsc" }
        exit 0
    }

    Write-Status "Najnowsza wersja     : $latestVersion" "White"

    if ($latestVersion -eq $currentVersion) {
        Write-Status "" "White"
        Write-Status "Masz najnowsza wersje! Nic do zrobienia." "Green"
        if ($Manual) { Read-Host "Nacisnij Enter aby wyjsc" }
        exit 0
    }

    Write-Status "" "White"
    Write-Status "Dostepna aktualizacja: $currentVersion -> $latestVersion" "Cyan"
    Write-Status "Pobieranie..." "Yellow"

    $dllUrl  = "https://github.com/$REPO/releases/download/$latestVersion/$DLL_NAME"
    $tmpPath = "$env:TEMP\TouUpdate_$latestVersion.dll"

    Invoke-WebRequest -Uri $dllUrl -OutFile $tmpPath -UseBasicParsing

    if (-not (Test-Path $tmpPath)) {
        Write-Status "[BLAD] Nie udalo sie pobrac pliku." "Red"
        if ($Manual) { Read-Host "Nacisnij Enter aby wyjsc" }
        exit 1
    }
    if ((Get-Item $tmpPath).Length -lt 1024) {
        Remove-Item $tmpPath -Force
        Write-Status "[BLAD] Pobrany plik jest uszkodzony." "Red"
        if ($Manual) { Read-Host "Nacisnij Enter aby wyjsc" }
        exit 1
    }

    # Sprawdz czy Among Us nie jest uruchomiony
    $gameRunning = Get-Process -Name "Among Us" -ErrorAction SilentlyContinue
    if ($gameRunning) {
        $msg = "Dostepna aktualizacja $latestVersion. Zamknij gre, aby zainstalowac."
        Write-Status "" "White"
        Write-Status "[!] $msg" "Yellow"
        Show-Toast "ToU Tobiasz Edition" $msg
        Remove-Item $tmpPath -Force -ErrorAction SilentlyContinue
        if ($Manual) { Read-Host "Nacisnij Enter aby wyjsc" }
        exit 0
    }

    # Podmien DLL
    New-Item -ItemType Directory -Path $PLUGINS_DIR -Force | Out-Null
    $dllPath = "$PLUGINS_DIR\$DLL_NAME"
    Move-Item -Path $tmpPath -Destination $dllPath -Force

    Set-Content -Path $VERSION_FILE -Value $latestVersion -Encoding UTF8

    $msg = "Zaktualizowano do $latestVersion! Uruchom gre, aby uzywac nowych rol."
    Write-Status "" "White"
    Write-Status "OK - $msg" "Green"
    Show-Toast "ToU Tobiasz Edition" $msg

    if ($Manual) { Read-Host "Nacisnij Enter aby wyjsc" }
}
catch {
    Write-Status "[BLAD] Brak internetu lub GitHub niedostepny." "Red"
    if ($Manual) { Read-Host "Nacisnij Enter aby wyjsc" }
    exit 0
}
