# ToU Tobiasz Edition

Custom roles mod dla **Among Us** oparty na Town of Us: Mira.
Trzy unikalne role stworzone na podstawie prawdziwych osob: Emil, Jonasz i Adam.

**Strona pobierania:** https://santobinoofficial.github.io/tou-tobiasz-edition/

---

## Role

### Emil — Neutral Killing

Powolny i glodny. Zabija graczy i musi pozrec kazde cialo zanim przejdzie do nastepnego. Zjedzone ciala znikaja i nie moga byc zglaszane. Wygrywa gdy nie ma zywych przeciwnikow i wszystkie ciala zostaly zjedzone.

**Zdolnosci:** Zabijanie, Pozieranie cial, Zmniejszona predkosc, Wentylacja (opcja)

### Jonasz — Crewmate Investigative

Maly i szybki. Wysyla ptaki by wykrywac impostorów - ptak wraca z wynikiem zielonym (niewinny) lub czerwonym (impostor). Moze uzyc Dasha by gwaltownie przyspieszyc i uciec z zagrozenia.

**Zdolnosci:** Ptak - wykrywanie, Dash - ucieczka, Zwiekszony speed

### Adam — Impostor Killing

Dymi cala okolice. Aktywuje chmure dymu wokol siebie, ktora drastycznie redukuje widzenie pobliskich Crewmate'ow. Impostorzy widza przez dym normalnie. Uzyj dymu by ukryc zabojstwo lub uciec.

**Zdolnosci:** Dym - slepota (20% wizji), Wentylacja, Zabijanie

---

## Instalacja

### Krok 1 - Pobierz Zainstaluj.bat

https://github.com/SanTobinoOfficial/tou-tobiasz-edition/releases/latest/download/Zainstaluj.bat

### Krok 2 - Kliknij dwukrotnie

Dwukrotnie kliknij pobrany plik `Zainstaluj.bat`.

Jesli pojawi sie ostrzezenie SmartScreen → **"Wiecej informacji"** → **"Uruchom mimo to"**.

Instalator automatycznie:
- Kopiuje Among Us do osobnego folderu (vanilla pozostaje nienaruszona)
- Instaluje Town of Us: Mira 1.6.3
- Pobiera mod (TouTobiaszEdition.dll)
- Konfiguruje automatyczne aktualizacje (Windows Task Scheduler)

### Krok 3 - Poczekaj ok. 2 minuty

Instalator dziala w pelni automatycznie. Domyslnie instaluje na Pulpit.
Uruchamiajac `install.ps1` bezposrednio (bez Zainstaluj.bat) mozna wybrac folder strzalkami.

### Krok 4 - Uruchom gre

Uruchom `Among Us - Tobiasz Edition\Among Us.exe` z Pulpitu (lub wybranego folderu).

> **Wazne:** Uruchamiaj bezposrednio przez `.exe`, NIE przez Steam/Epic!

---

## Trzy osobne kopie gry

| Kopia | Lokalizacja | Opis |
|-------|-------------|------|
| Vanilla | Steam / Epic | Normalny Among Us bez modow, uruchamiaj przez launcher jak zawsze |
| TOU:Mira | Twoj folder | Jezeli masz wlasna instalacje TOU, pozostaje w swoim folderze |
| Tobiasz Edition | Pulpit (domyslnie) | Nasz mod, oddzielny folder, uruchamiaj bezposrednio .exe |

---

## Automatyczne aktualizacje

Skrypt instalacyjny rejestruje zadanie `"ToU Tobiasz Edition Updater"` w Windows Task Scheduler.
Przy kazdym logowaniu do systemu sprawdza GitHub API czy dostepna jest nowsza wersja moda.

Jezeli tak - pobiera nowy DLL i pokazuje powiadomienie Windows Toast.
Zero interwencji z Twojej strony.

| Parametr | Wartosc |
|----------|---------|
| Wyzwalacz | Przy logowaniu do systemu |
| Sprawdza | GitHub API - najnowszy release tag |
| Aktualizuje | Tylko TouTobiaszEdition.dll |
| Powiadamia | Windows Toast Notification |
| Zadanie | "ToU Tobiasz Edition Updater" w Task Scheduler |

Mozna tez recznie sprawdzic aktualizacje — uruchom `Sprawdz aktualizacje.bat` z folderu gry.

---

## Wymagania systemowe

| | |
|-|--|
| System | Windows 10/11 (x64) |
| Gra | Among Us (Steam lub Epic Games) |
| Wersja AU | 2026.6.5 lub nowsza |
| TOU:Mira | 1.6.3 (instalowany automatycznie) |
| Dysk | ok. 2 GB wolnego miejsca |
| Internet | Tylko przy instalacji i aktualizacjach |

---

## Changelog

### v1.0.7 — 2026-06-29
- Naprawa bledu enkodowania Unicode w instalatorze (UTF-8 BOM)
- PowerShell 5.1 czyta plik jako ANSI bez BOM — znaki ramek i spinner wyswietlaly sie jako smieci
- install.ps1 zapisany z BOM (EF BB BF); Zainstaluj.bat dodaje BOM po pobraniu

### v1.0.6 — 2026-06-29
- Piekny instalator TUI ze spinnerem pobierania i ramkami w stylu OpenCode
- Menu nawigowane strzalkami (gora/dol + Enter) — wybor launchera i folderu instalacji
- Domyslna lokalizacja zmieniona na Pulpit
- Tryb -Silent (Zainstaluj.bat): zero pytan, pelna automatyzacja

### v1.0.5 — 2026-06-29
- Naprawa krytycznego bledu: ZIP bez podfolderu kopiowal caly dysk C:\ do folderu gry
- Bezpieczne wyodrebnianie archiwum — null-safe $src
- Tryb -Silent w instalatorze
- Zainstaluj.bat przekazuje -Silent automatycznie

### v1.0.4 — 2026-06-29
- Wsparcie dla Epic Games — instalator wykrywa Among Us w Epic Games Launcher
- Wybor folderu instalacji: Games, Pulpit lub wlasna sciezka
- Sciezka instalacji zapisywana do %LOCALAPPDATA%\TouTobiaszEdition\install_path.txt
- Sprawdz aktualizacje.bat w folderze gry — reczne uruchomienie updatera

### v1.0.3 — 2026-06-29
- Naprawa bledow kompilacji roli Adam (CS0246, CS0115, CS0426)
- Poprawny namespace Reactor dla RPC, metoda CanUse() w buttonie, NetworkedPlayerInfo w patchu wizji

### v1.0.2 — 2026-06-29
- Nowa rola Adam (Impostor Killing): zdolnosc Dym redukujaca widzenie pobliskim Crewmate'om do 20%
- Dym w konfigurowalnym promieniu (domyslnie 5j), trwa 8s, cooldown 25s
- Impostorzy widza przez dym normalnie
- AdamOptions: SmokeCooldown, SmokeDuration, SmokeRadius, VisionMultiplier

### v1.0.1 — 2026-06-29
- Nowa strona GitHub Pages w stylu Steam (dark navy, karty rol, panel pobierania)
- Automatyczne aktualizacje przez Windows Task Scheduler
- `update.ps1` - updater pobierany razem z modem do folderu instalacji
- `install.ps1` - rejestruje zadanie w Task Scheduler, zapisuje `tou_version.txt`

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
