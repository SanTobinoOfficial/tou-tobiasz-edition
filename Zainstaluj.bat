@echo off
chcp 65001 > nul
title ToU Tobiasz Edition

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference='SilentlyContinue'; $f=\"$env:TEMP\tou_install.ps1\"; Invoke-WebRequest 'https://github.com/SanTobinoOfficial/tou-tobiasz-edition/releases/latest/download/install.ps1' -OutFile $f -UseBasicParsing; $b=[IO.File]::ReadAllBytes($f); [IO.File]::WriteAllBytes($f,[byte[]](0xEF,0xBB,0xBF)+$b); Unblock-File $f"
if errorlevel 1 (
    echo.
    echo [BLAD] Nie mozna pobrac instalatora. Sprawdz polaczenie z internetem.
    pause
    exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMP%\tou_install.ps1" -Silent
set EXITCODE=%ERRORLEVEL%
del "%TEMP%\tou_install.ps1" 2>nul

if %EXITCODE% neq 0 (
    echo.
    echo [BLAD] Instalacja nie powiodla sie ^(kod: %EXITCODE%^).
    echo Przewin okno w gore, aby zobaczyc szczegoly.
    pause
    exit /b %EXITCODE%
)

pause
