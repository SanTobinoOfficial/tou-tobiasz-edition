# ToU Tobiasz Edition 🎮

Custom roles mod for **Among Us**, based on Town of Us: Mira.

## Role

| Rola | Drużyna | Opis |
|------|---------|------|
| **Emil** | Neutral | Powolny pożeracz. Musi zjeść ciała wszystkich graczy. Zabija i wraca po ciało. Wygrywam gdy wszystkie ciała są zjedzone i nie ma żywych wrogów. |
| **Jonasz** | Crewmate | Mały i szybki. Używa ptaków do wykrywania impostorów (zielony = bezpieczny, czerwony = impostor) i Dasha do szybkiej ucieczki. |

---

## Instalacja dla znajomych ✅

### Krok 1 — Pobierz autoinstalator

👉 **[Kliknij tutaj aby pobrać install.ps1](https://github.com/SanTobinoOfficial/tou-tobiasz-edition/releases/latest/download/install.ps1)**

### Krok 2 — Uruchom

Kliknij **prawym przyciskiem** na `install.ps1` → **Uruchom za pomocą programu PowerShell**

Skrypt automatycznie:
- Stworzy osobną kopię Among Us (vanilla pozostaje nienaruszona!)
- Zainstaluje Town of Us: Mira 1.6.3
- Zainstaluje nasze role (Emil, Jonasz)

### Krok 3 — Graj

Uruchom `C:\Games\Among Us - Tobiasz Edition\Among Us.exe`

> ⚠️ Nie uruchamiaj przez Steam — uruchamiaj `Among Us.exe` bezpośrednio z folderu gry!

---

## Jak działają osobne kopie

```
Steam (vanilla)          →  normalny Among Us, bez modów
Among Us - Tobiasz Edition  →  TOU:Mira + Emil + Jonasz
```

Możesz mieć oba naraz — Steam uruchamia czystą wersję, a nasz folder ma mody.

---

## Dla deweloperów

```bash
git clone https://github.com/SanTobinoOfficial/tou-tobiasz-edition
cd tou-tobiasz-edition
dotnet build TouExtensionExample/TouExtensionExample.csproj
```

---

*This mod is not affiliated with Among Us or Innersloth LLC. © Innersloth LLC.*
*Based on [TouExtensionExample](https://github.com/AU-Avengers/TouExtensionExample) by AU-Avengers. Licensed under GNU GPLv3.*
