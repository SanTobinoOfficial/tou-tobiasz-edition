# ToU Tobiasz Edition - Auto-Updater
# Uruchamiany automatycznie przez Windows Task Scheduler przy logowaniu.
# NIE uruchamiaj recznie - plik ten jest zarzadzany przez instalator.

$ErrorActionPreference = "SilentlyContinue"
$ProgressPreference    = "SilentlyContinue"

$REPO         = "SanTobinoOfficial/tou-tobiasz-edition"
$INSTALL_DIR  = "C:\Games\Among Us - Tobiasz Edition"
$VERSION_FILE = "$INSTALL_DIR\tou_version.txt"
$PLUGINS_DIR  = "$INSTALL_DIR\BepInEx\plugins"
$DLL_NAME     = "TouTobiaszEdition.dll"
$API_URL      = "https://api.github.com/repos/$REPO/releases/latest"

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

# Sprawdz czy mod jest zainstalowany
if (-not (Test-Path "$INSTALL_DIR\Among Us.exe")) { exit 0 }

# Zaladuj aktualnie zainstalowana wersje
$currentVersion = "v0.0.0"
if (Test-Path $VERSION_FILE) {
    $currentVersion = (Get-Content $VERSION_FILE -Raw -ErrorAction SilentlyContinue).Trim()
}

# Sprawdz GitHub API
try {
    $release = Invoke-RestMethod `
        -Uri $API_URL `
        -UseBasicParsing `
        -Headers @{ "User-Agent" = "TouTobiaszEdition-Updater/1.0" }

    $latestVersion = $release.tag_name.Trim()
    if ([string]::IsNullOrEmpty($latestVersion)) { exit 0 }

    # Jestesmy aktualni
    if ($latestVersion -eq $currentVersion) { exit 0 }

    # Pobierz nowy DLL
    $dllUrl  = "https://github.com/$REPO/releases/download/$latestVersion/$DLL_NAME"
    $tmpPath = "$env:TEMP\TouUpdate_$latestVersion.dll"

    Invoke-WebRequest -Uri $dllUrl -OutFile $tmpPath -UseBasicParsing

    if (-not (Test-Path $tmpPath)) { exit 1 }
    if ((Get-Item $tmpPath).Length -lt 1024) { Remove-Item $tmpPath -Force; exit 1 }

    # Sprawdz czy Among Us nie jest uruchomiony (DLL bylby zablokowany)
    $gameRunning = Get-Process -Name "Among Us" -ErrorAction SilentlyContinue
    if ($gameRunning) {
        Show-Toast "ToU Tobiasz Edition" "Dostepna aktualizacja $latestVersion. Zamknij gre, aby zainstalowac."
        Remove-Item $tmpPath -Force -ErrorAction SilentlyContinue
        exit 0
    }

    # Podmien DLL
    New-Item -ItemType Directory -Path $PLUGINS_DIR -Force | Out-Null
    $dllPath = "$PLUGINS_DIR\$DLL_NAME"
    Move-Item -Path $tmpPath -Destination $dllPath -Force

    # Zapisz nowa wersje
    Set-Content -Path $VERSION_FILE -Value $latestVersion -Encoding UTF8

    Show-Toast "ToU Tobiasz Edition" "Zaktualizowano do $latestVersion! Uruchom gre, aby uzywac nowych rol."
}
catch {
    # Brak internetu, GitHub niedostepny - cicha awaria
    exit 0
}
