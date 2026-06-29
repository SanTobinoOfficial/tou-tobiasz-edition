# ToU Tobiasz Edition

Custom roles mod dla **Among Us** oparty na Town of Us: Mira.
Dwie nowe role stworzone na podstawie prawdziwych osob: Emil i Jonasz.

**Strona pobierania:** https://santobinoofficial.github.io/tou-tobiasz-edition/

---

## Role

### Emil — Neutral Killing

Powolny i glodny. Zabija graczy i musi pozrec kazde cialo zanim przejdzie do nastepnego. Zjedzone ciala znikaja i nie moga byc zglaszane. Wygrywa gdy nie ma zywych przeciwnikow i wszystkie ciala zostaly zjedzone.

**Zdolnosci:** Zabijanie, Pozieranie cial, Zmniejszona predkosc, Wentylacja (opcja)

### Jonasz — Crewmate Investigative

Maly i szybki. Wysyla ptaki by wykrywac impostorów - ptak wraca z wynikiem zielonym (niewinny) lub czerwonym (impostor). Moze uzyc Dasha by gwaltownie przyspieszyc i uciec z zagrozenia.

**Zdolnosci:** Ptak - wykrywanie, Dash - ucieczka, Zwiekszony speed

---

## Instalacja

### Krok 1 - Pobierz autoinstalator

Pobierz z najnowszego release:
https://github.com/SanTobinoOfficial/tou-tobiasz-edition/releases/latest/download/install.ps1

### Krok 2 - Odblokuj plik (wazne!)

Windows blokuje skrypty pobrane z internetu. Przed uruchomieniem:

**Opcja A** — Prawym przyciskiem na `install.ps1` → **Wlasciwosci** → zaznacz **"Odblokuj"** → OK

**Opcja B** — Wklej do PowerShell:
```powershell
Unblock-File "$env:USERPROFILE\Downloads\install.ps1"
```

### Krok 3 - Uruchom PowerShell

Prawym przyciskiem na `install.ps1` -> "Uruchom za pomoca programu PowerShell"

Skrypt automatycznie:
- Kopiuje Among Us do osobnego folderu (vanilla pozostaje nienaruszona)
- Instaluje Town of Us: Mira 1.6.3
- Pobiera mod (TouTobiaszEdition.dll)
- Konfiguruje automatyczne aktualizacje (Windows Task Scheduler)

### Krok 4 - Uruchom gre

Uruchom `C:\Games\Among Us - Tobiasz Edition\Among Us.exe`

> **Wazne:** Uruchamiaj bezposrednio przez `.exe`, NIE przez Steam/Epic!

---

## Trzy osobne kopie gry

| Kopia | Lokalizacja | Opis |
|-------|-------------|------|
| Vanilla | Steam | Normalny Among Us bez modow, uruchamiaj przez Steam jak zawsze |
| TOU:Mira | Twoj folder | Jezeli masz wlasna instalacje TOU, pozostaje w swoim folderze |
| Tobiasz Edition | `C:\Games\Among Us - Tobiasz Edition\` | Nasz mod, oddzielny folder |

---

## Automatyczne aktualizacje

Skrypt instalacyjny rejestruje zadanie `"ToU Tobiasz Edition Updater"` w Windows Task Scheduler.
Przy kazdym logowaniu do systemu (z 30-sekundowym opoznieniem) sprawdza GitHub API
czy dostepna jest nowsza wersja moda.

Jezeli tak - pobiera nowy DLL i pokazuje powiadomienie Windows Toast.
Jezeli Among Us jest uruchomiony - wyswietla komunikat "Zamknij gre, aby zainstalowac".
Zero interwencji z Twojej strony.

| Parametr | Wartosc |
|----------|---------|
| Wyzwalacz | Przy logowaniu do systemu (opoznienie 30s) |
| Sprawdza | GitHub API - najnowszy release tag |
| Aktualizuje | Tylko TouTobiaszEdition.dll |
| Powiadamia | Windows Toast Notification |
| Zadanie | "ToU Tobiasz Edition Updater" w Task Scheduler |

---

## Wymagania systemowe

| | |
|-|--|
| System | Windows 10/11 (x64) |
| Gra | Among Us (Steam) |
| Wersja AU | 2026.6.5 lub nowsza |
| TOU:Mira | 1.6.3 (instalowany automatycznie) |
| Dysk | ok. 2 GB wolnego miejsca |
| Internet | Tylko przy instalacji i aktualizacjach |

---

## Changelog

### v1.0.3 — 2026-06-29
- Naprawa bledu kompilacji roli Adam (CS0246, CS0115, CS0426)
- Poprawny namespace Reactor dla RPC, poprawna metoda CanUse() w buttonie, NetworkedPlayerInfo w patchu wizji

### v1.0.2 — 2026-06-29
- Nowa rola Adam (Impostor): zdolnosc Dym redukujaca widzenie pobliskim Crewmate'om do 20%
- Dym dziala w promieniu konfigurowalnym (domyslnie 5 jednostek), trwa 8 sekund, cooldown 25s
- Impostorzy widza przez dym normalnie
- AdamOptions: SmokeCooldown, SmokeDuration, SmokeRadius, VisionMultiplier

### v1.0.1 — 2026-06-29
- Nowa strona GitHub Pages w stylu Steam (dark navy, karty rol, panel pobierania)
- Automatyczne aktualizacje przez Windows Task Scheduler
- `update.ps1` - updater pobierany razem z modem do folderu instalacji
- `install.ps1` - rejestruje zadanie w Task Scheduler, zapisuje `tou_version.txt`
- README zsynchronizowany ze strona

### v1.0.0 — 2026-06-29
- Pierwsze wydanie
- Rola Emil (Neutral Killing): pozieranie cial, zmniejszona predkosc
- Rola Jonasz (Crewmate Investigative): ptak-detektor, dash
- Autoinstalator `install.ps1` - kopiuje Among Us, instaluje TOU:Mira i mod
- GitHub Actions: automatyczny build DLL po tagu
- GitHub Pages: strona pobierania

---

## Dla deweloperow

```bash
git clone https://github.com/SanTobinoOfficial/tou-tobiasz-edition
cd tou-tobiasz-edition
dotnet build TouExtensionExample/TouExtensionExample.csproj
```

Zmienna srodowiskowa `$AmongUs` ustawiona na folder gry automatycznie kopiuje DLL do pluginow po buildzie.

---

*Ten mod nie jest powiazany z Innersloth LLC. (c) Innersloth LLC.*
*Oparty na [TouExtensionExample](https://github.com/AU-Avengers/TouExtensionExample) - GNU GPLv3.*
