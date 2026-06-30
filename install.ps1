# ToU Tobiasz Edition — Autoinstalator
param([switch]$Silent)

$ErrorActionPreference = "Stop"
$ProgressPreference    = "SilentlyContinue"
[Console]::OutputEncoding = [Text.Encoding]::UTF8

$REPO        = "SanTobinoOfficial/tou-tobiasz-edition"
$GAME_NAME   = "Among Us - Tobiasz Edition"
$TOU_ZIP_URL = "https://github.com/AU-Avengers/TOU-Mira/releases/download/1.6.2/TouMira-v1.6.2-x86-steam-itch.zip"
$TOU_DLL_URL = "https://github.com/AU-Avengers/TOU-Mira/releases/download/1.6.3/TownOfUsMira.dll"
$API_URL     = "https://api.github.com/repos/$REPO/releases/latest"
$TMP         = "$env:TEMP\TouInstall_$(Get-Random)"
$CONFIG_DIR  = "$env:LOCALAPPDATA\TouTobiaszEdition"
$CONFIG_FILE = "$CONFIG_DIR\install_path.txt"
$STEAM_DIR   = "C:\Program Files (x86)\Steam\steamapps\common\Among Us"
$EPIC_DIRS   = @(
    "C:\Program Files\Epic Games\Among Us"
    "C:\Program Files (x86)\Epic Games\Among Us"
)
$DESKTOP = [Environment]::GetFolderPath('Desktop')

# ── UI prymitywy ────────────────────────────────────────────────────────────
function ln  { Write-Host "" }
function ok($m)  { Write-Host "  ✓  $m" -ForegroundColor Green }
function er($m)  { Write-Host "  ✗  $m" -ForegroundColor Red }
function inf($m) { Write-Host "  ·  $m" -ForegroundColor DarkGray }
function hi($t, $c = "White") { Write-Host $t -ForegroundColor $c }

function header {
    $s = "═" * 60
    hi "╔$s╗" Cyan
    hi "║$("  ToU Tobiasz Edition".PadRight(60))║" Cyan
    hi "║$("  Instalator v1.0.6".PadRight(60))║" DarkCyan
    hi "╠$s╣" DarkCyan
    $os   = try { (Get-CimInstance Win32_OperatingSystem).Caption } catch { "Windows" }
    $mode = if ($Silent) { "Automatyczny (zero pytan)" } else { "Interaktywny  ↑↓ = nawigacja  Enter = wybor" }
    hi "║$("  Platforma : $os".PadRight(60))║" DarkGray
    hi "║$("  Tryb      : $mode".PadRight(60))║" DarkGray
    hi "╚$s╝" Cyan
    ln
}

function step($n, $t, $title) {
    ln
    hi "  $("─" * 58)" DarkCyan
    hi "  $n/$t  $title" White
    hi "  $("─" * 58)" DarkCyan
    ln
}

# TUI menu ze strzalkami — zwraca wybrany indeks
function menu($prompt, $options, $default = 0) {
    inf $prompt
    $sel   = $default
    $count = $options.Count

    # kursor ukryty podczas nawigacji
    try { [Console]::CursorVisible = $false } catch {}

    # render wszystkich opcji
    $startRow = [Console]::CursorTop
    foreach ($i in 0..($count - 1)) {
        $isDefault = ($i -eq $default)
        $tag       = if ($isDefault) { " (domyslne)" } else { "" }
        if ($i -eq $sel) {
            hi ("  ❯  " + $options[$i] + $tag) Cyan
        } else {
            hi ("     " + $options[$i] + $tag) DarkGray
        }
    }

    :loop while ($true) {
        $k = [Console]::ReadKey($true)
        switch ($k.Key) {
            "UpArrow"   { if ($sel -gt 0)          { $sel-- } }
            "DownArrow" { if ($sel -lt $count - 1) { $sel++ } }
            "Enter"     { break loop }
            "Escape"    { $sel = $default; break loop }
        }
        # przerysuj
        [Console]::SetCursorPosition(0, $startRow)
        foreach ($i in 0..($count - 1)) {
            $isDefault = ($i -eq $default)
            $tag       = if ($isDefault) { " (domyslne)" } else { "" }
            $pad       = " " * 6
            if ($i -eq $sel) {
                hi ("  ❯  " + $options[$i] + $tag + $pad) Cyan
            } else {
                hi ("     " + $options[$i] + $tag + $pad) DarkGray
            }
        }
    }

    # zamien menu na pojedyncza linie z wynikiem
    [Console]::SetCursorPosition(0, $startRow)
    for ($i = 0; $i -lt $count; $i++) { Write-Host (" " * 78) }
    [Console]::SetCursorPosition(0, $startRow)
    ok $options[$sel]
    try { [Console]::CursorVisible = $true } catch {}

    return $sel
}

# pobieranie z animowanym spinnerem
function dl($url, $out, $label) {
    $spin = '⠋','⠙','⠹','⠸','⠼','⠴','⠦','⠧','⠇','⠏'
    $j = Start-Job {
        param($u,$f)
        $ProgressPreference = "SilentlyContinue"
        Invoke-WebRequest -Uri $u -OutFile $f -UseBasicParsing
    } -ArgumentList $url,$out
    $i = 0
    try { $row = [Console]::CursorTop } catch { $row = -1 }
    while ($j.State -eq 'Running') {
        $kb = if (Test-Path $out) { "$([math]::Round((Get-Item $out -EA 0).Length / 1KB)) KB" } else { "..." }
        if ($row -ge 0) {
            [Console]::SetCursorPosition(0, $row)
            Write-Host ("  $($spin[$i % 10])  $label  [$kb]" + " " * 10) -ForegroundColor DarkCyan -NoNewline
        }
        Start-Sleep -Milliseconds 80
        $i++
    }
    Receive-Job $j -ErrorAction Stop | Out-Null
    Remove-Job $j
    if ($row -ge 0) {
        [Console]::SetCursorPosition(0, $row); Write-Host (" " * 76)
        [Console]::SetCursorPosition(0, $row)
    }
    ok "$label  ($([math]::Round((Get-Item $out).Length / 1KB)) KB)"
}

function finish($ver, $dir) {
    ln
    $s   = "═" * 60
    $exe = if ($dir.Length -gt 44) { "..." + $dir.Substring($dir.Length - 41) } else { $dir }
    hi "╔$s╗" Green
    hi "║$("  ✓  Instalacja zakonczona pomyslnie!".PadRight(60))║" Green
    hi "╠$s╣" DarkGreen
    hi "║$("  Wersja moda  :  $ver".PadRight(60))║" White
    hi "║$("  Folder gry   :  $exe".PadRight(60))║" Cyan
    hi "║$(" " * 60)║" DarkGreen
    hi "║$("  Uruchamiaj .exe bezposrednio — NIE przez Steam/Epic!".PadRight(60))║" Yellow
    hi "╚$s╝" Green
    ln
}

# ── MAIN ───────────────────────────────────────────────────────────────────
Clear-Host
header

# 1 — wykryj grę
step 1 5 "Wykrywanie Among Us"

$steamOk = Test-Path "$STEAM_DIR\Among Us.exe"
$epicDir  = $EPIC_DIRS | Where-Object { Test-Path "$_\Among Us.exe" } | Select-Object -First 1
$epicOk   = $null -ne $epicDir

if (-not $steamOk -and -not $epicOk) {
    er "Nie znaleziono Among Us (Steam ani Epic)"
    inf "Zainstaluj Among Us przez Steam lub Epic i sprobuj ponownie."
    ln; if (-not $Silent) { $null = [Console]::ReadKey($true) }; exit 1
}

$SOURCE_DIR = $null
if ($steamOk -and $epicOk -and -not $Silent) {
    $idx = menu "Znaleziono Among Us w Steam i Epic — wybierz kopie:" @(
        "Steam   →  $STEAM_DIR"
        "Epic    →  $epicDir"
    ) 0
    $SOURCE_DIR = if ($idx -eq 0) { $STEAM_DIR } else { $epicDir }
} elseif ($steamOk) {
    $SOURCE_DIR = $STEAM_DIR; ok "Among Us (Steam) — $STEAM_DIR"
} else {
    $SOURCE_DIR = $epicDir;   ok "Among Us (Epic) — $epicDir"
}

# 2 — folder instalacji
step 2 5 "Folder instalacji"

$INSTALL_DIR = "$DESKTOP\$GAME_NAME"   # <— domyslnie: Pulpit

if (-not $Silent) {
    $idx = menu "Gdzie zainstalowac moda?" @(
        "Pulpit         →  $DESKTOP\$GAME_NAME"
        "Folder Games   →  C:\Games\$GAME_NAME"
        "Wlasna sciezka →  wpisz recznie"
    ) 0
    switch ($idx) {
        0 { $INSTALL_DIR = "$DESKTOP\$GAME_NAME" }
        1 { $INSTALL_DIR = "C:\Games\$GAME_NAME" }
        2 {
            ln
            do { $p = (Read-Host "  Sciezka instalacji").Trim().Trim('"') } while ([string]::IsNullOrWhiteSpace($p))
            $INSTALL_DIR = $p
        }
    }
} else {
    ok "Pulpit — $INSTALL_DIR"
}

New-Item -ItemType Directory -Path $CONFIG_DIR -Force | Out-Null
Set-Content -Path $CONFIG_FILE -Value $INSTALL_DIR -Encoding UTF8

# 3 — kopiuj Among Us
step 3 5 "Kopiowanie Among Us"

New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null
inf "Kopiowanie plików gry (moze potrwac chwile)..."
Copy-Item "$SOURCE_DIR\*" $INSTALL_DIR -Recurse -Force
$count = (Get-ChildItem $INSTALL_DIR -Recurse -File).Count
ok "Skopiowano $count plików"

# 4 — TOU:Mira
step 4 5 "Town of Us: Mira 1.6.3"

New-Item -ItemType Directory -Path $TMP -Force | Out-Null
$zipPath     = "$TMP\toumira.zip"
$extractPath = "$TMP\toumira"
dl $TOU_ZIP_URL $zipPath "TouMira-v1.6.2-x86-steam-itch.zip"
inf "Rozpakowywanie..."
Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
$subDir = Get-ChildItem $extractPath -Directory | Select-Object -First 1
$src    = if ($null -ne $subDir) { $subDir.FullName } else { $extractPath }
Copy-Item "$src\*" $INSTALL_DIR -Recurse -Force

$pluginsDirMira = "$INSTALL_DIR\BepInEx\plugins"
New-Item -ItemType Directory -Path $pluginsDirMira -Force | Out-Null
dl $TOU_DLL_URL "$pluginsDirMira\TownOfUsMira.dll" "TownOfUsMira.dll v1.6.3"
ok "TOU:Mira 1.6.3 zainstalowany"

# 5 — mod DLL + updater
step 5 5 "ToU Tobiasz Edition + auto-updater"

try {
    $rel = Invoke-RestMethod -Uri $API_URL -UseBasicParsing -Headers @{ "User-Agent" = "TouTobiaszInstaller/1.0" }
    $ver = $rel.tag_name.Trim()
} catch { $ver = "v1.0.6" }

$pluginsDir = "$INSTALL_DIR\BepInEx\plugins"
New-Item -ItemType Directory -Path $pluginsDir -Force | Out-Null
dl "https://github.com/$REPO/releases/download/$ver/TouTobiaszEdition.dll" `
   "$pluginsDir\TouTobiaszEdition.dll" "TouTobiaszEdition.dll"
Set-Content -Path "$INSTALL_DIR\tou_version.txt" -Value $ver -Encoding UTF8

$upd = "$INSTALL_DIR\update.ps1"
try { Invoke-WebRequest -Uri "https://github.com/$REPO/releases/download/$ver/update.ps1" -OutFile $upd -UseBasicParsing } catch {}
Set-Content -Path "$INSTALL_DIR\Sprawdz aktualizacje.bat" `
    -Value "@echo off`r`npowershell.exe -ExecutionPolicy Bypass -WindowStyle Normal -File ""%~dp0update.ps1"" -Manual`r`n" `
    -Encoding ASCII

if (Test-Path $upd) {
    $tn  = "ToU Tobiasz Edition Updater"
    $act = New-ScheduledTaskAction -Execute "powershell.exe" `
           -Argument "-WindowStyle Hidden -NonInteractive -ExecutionPolicy Bypass -File `"$upd`""
    $trg = New-ScheduledTaskTrigger -AtLogon -User $env:USERNAME
    $set = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 5) `
           -StartWhenAvailable -MultipleInstances IgnoreNew
    Unregister-ScheduledTask -TaskName $tn -Confirm:$false -EA SilentlyContinue
    Register-ScheduledTask -TaskName $tn -Action $act -Trigger $trg -Settings $set -RunLevel Limited -Force | Out-Null
    ok "Auto-updater zarejestrowany (Task Scheduler)"
}

Remove-Item $TMP -Recurse -Force -EA SilentlyContinue

finish $ver $INSTALL_DIR
if (-not $Silent) { $null = [Console]::ReadKey($true) }
