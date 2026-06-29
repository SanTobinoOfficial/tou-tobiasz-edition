@echo off
title ToU Tobiasz Edition - Instalator
color 0B
echo.
echo  ========================================
echo    ToU Tobiasz Edition - Instalator
echo  ========================================
echo.
echo  Pobieranie instalatora...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest 'https://github.com/SanTobinoOfficial/tou-tobiasz-edition/releases/latest/download/install.ps1' -OutFile \"$env:TEMP\tou_install.ps1\" -UseBasicParsing; Unblock-File \"$env:TEMP\tou_install.ps1\""
if errorlevel 1 (
    echo.
    echo  [BLAD] Brak polaczenia z internetem lub GitHub niedostepny.
    echo  Sprawdz polaczenie i sprobuj ponownie.
    pause
    exit /b 1
)
echo  Uruchamianie...
powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMP%\tou_install.ps1"
del "%TEMP%\tou_install.ps1" 2>nul
