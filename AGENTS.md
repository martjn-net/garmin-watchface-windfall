# Windfall Watch Face — Garmin Descent G2

## Regeln

- **Niemals** das Design als Kopie/Inspiration eines anderen Smartwatch-Herstellers beschreiben. Keine "inspiriert von [Firma]"-Formulierungen. Design-Stil ist "modern-minimalistisch" oder "clean". Gilt für alle Texte, Memory, Code, Commits, Store-Listings.
- Technische Markennamen (Garmin, Java, VS Code etc.) sind erlaubt.
- Keine Garmin-eigenen Watch-Face-Designs nachbauen (Store-Regel seit Mai 2025)

## Projektübersicht

**Name:** Windfall (deutsch: Fallobst)
**Typ:** Watch Face für Garmin Descent G2
**Sprache:** Monkey C (Connect IQ SDK)
**Design:** Clean, modern-minimalistisch, eigenständig

## Gerätespezifikationen

- **Display:** 1.2" AMOLED, Touchscreen, 390x390 Pixel, rund
- **API Level:** Connect IQ 5.1
- **Sensoren:** HR, SpO2, Barometer, Kompass, GPS, Tiefensensor, Thermometer, Gyroskop
- **Besonderheit:** Tauchcomputer — alle CIQ-Features sind während Tauchgängen deaktiviert
- **Akku:** ~10 Tage Smartwatch, ~27h Dive Mode

## Technische Constraints

### Memory
- Ältere Geräte: 28 KB, neuere AMOLED: bis 124 KB
- Descent G2 hat mehr Spielraum, aber sparsam programmieren
- Kein OOP-Overkill — flache Hierarchien, wenige Objekte

### AMOLED-Regeln (Pflicht, sonst Store-Ablehnung)
- Always-On-Modus: Max 10% Pixel beleuchtet
- Burn-In-Protection: Elemente ±3px verschieben jede Minute
- Keine großen weißen/hellen Flächen
- Sekundenanzeige nur im aktiven Modus
- `onEnterSleep()` / `onExitSleep()` implementieren

### Allgemein
- Simulator ≠ echtes Gerät — immer auf Uhr testen
- `has` prüfen bevor Device-spezifische Methoden aufgerufen werden
- `hidden` statt `private` verwenden (weniger Build-Probleme)

## Design-System

### Farbpalette (AMOLED-optimiert)
- Hintergrund: #000000 (reines Schwarz, spart Akku)
- Primärtext (Zeit): #FFFFFF
- Sekundärtext (Datum, Metriken): #A0A0A0
- Akzent Grün: #34C759 (Aktivität)
- Akzent Blau: #007AFF (Wasser/Tauchen)
- Akzent Orange: #FF9500 (Warnungen/HR)
- Dezent: #333333 (Trennlinien, Ringe)

### Layout-Hierarchie
Zeit (groß, zentriert) > Datum (mittel, oben) > Komplikationen (klein, unten)

### Geplante Komplikationen
HR, Batterie, Schritte, Kalorien, Höhe/Tiefe, Wetter, Sonnenauf-/untergang

## Projektstruktur

```
source/
  WindfallApp.mc          # Entry Point
  WindfallView.mc         # WatchFace View (onUpdate)
  WindfallDelegate.mc     # Input Handler
  components/             # UI-Komponenten
  controllers/            # Daten-Controller
resources/
  drawables/              # Bilder, Icons
  fonts/                  # Custom Bitmap Fonts
  layouts/                # UI Layouts
  strings/                # Lokalisierung
  settings/               # On-Device Settings
```

## Code-Basis & Referenzen

- **Template:** `aurpelai/garmin-watchface-template` (MIT, MVC-Architektur)
- **Referenz:** `warmsound/crystal-face` (AMOLED, Performance, 712+ Commits)
- **AMOLED/AOD:** `fevieira27/MoveToBeActive` (beste AOD-Referenz, Memory-Optimierung)
- **Minimal:** `dbcm/KISSFace` (KISS-Prinzip)
- **Ökosystem:** `bombsimon/awesome-garmin` (226+ Watch Faces, kuratierte Liste)

## Entwicklungsumgebung (Ubuntu 24.04)

### Installierte Tools & Pfade
- **Java JDK 21** — `/usr/lib/jvm/java-21-openjdk-amd64` (JAVA_HOME in `~/.bashrc`)
- **VS Code** + **Monkey C Extension** `garmin.monkey-c` v1.1.3
- **Connect IQ SDK 9.1.0** — `~/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/`
- **SDK Manager CLI** — `~/go/bin/connect-iq-sdk-manager-cli` (Go-Binary, `lindell/connect-iq-sdk-manager-cli`)
- **Simulator AppImage** — `~/.Garmin/ConnectIQ/AppImages/Connect_IQ_Simulator-9.1.0+159-x86_64.AppImage` (von `pcolby/connectiq-sdk-manager`)
- **Developer Key** — `~/.Garmin/ConnectIQ/developer_key.der` (RSA 4096, DER-Format)
- **Device Fonts** — `~/.Garmin/ConnectIQ/Fonts/` (mit `--include-fonts` heruntergeladen!)
- **Current SDK Config** — `~/.Garmin/ConnectIQ/current-sdk.cfg`

### Bekannte Probleme auf Ubuntu 24.04
- Der native Garmin-Simulator braucht `libwebkit2gtk-4.0`, Ubuntu 24.04 hat nur `4.1`
- Symlink-Workaround funktioniert NICHT (libsoup2/3 Konflikt)
- **Lösung:** Simulator als AppImage von `pcolby/connectiq-sdk-manager` verwenden
- SDK Manager GUI hat dasselbe Problem → AppImage oder CLI nutzen

### Build & Test Workflow
1. **Build:** `monkeyc -d descentg2 -f monkey.jungle -o bin/WindfallApp.prg -y ~/.Garmin/ConnectIQ/developer_key.der -w`
2. **Simulator starten:** `~/.Garmin/ConnectIQ/AppImages/Connect_IQ_Simulator-*.AppImage`
3. **Watch Face laden:** `monkeydo bin/WindfallApp.prg descentg2`
4. **Oder in VS Code:** F5 → "Run on Descent G2" (launch.json konfiguriert)
5. **Sideload:** `Build for Device` → `.prg` nach `GARMIN/Apps/` auf der Uhr kopieren

### Wichtig: Device Fonts herunterladen
Beim Download von Device Files immer `--include-fonts` angeben:
```bash
connect-iq-sdk-manager-cli device download -d descentg2 --include-fonts
```
Ohne Fonts crasht der Simulator mit "Invalid Font Specified".

## Veröffentlichung

- Developer Account kostenlos, EEA-Identitätsverifizierung nötig
- Kostenlose App: Kein Gewerbe in DE nötig
- Bei Monetarisierung: Gewerbe anmelden, Kleinunternehmerregelung möglich
- Garmin nimmt 15% Provision (vs. 30% bei anderen Plattformen)

## Dokumentation im Repo

| Datei | Inhalt |
|-------|--------|
| `research_open_source.md` | Open-Source-Projekte, Monkey C, API, Projektstruktur |
| `dev_environment_setup.md` | Linux-Setup Schritt für Schritt |
| `implementation_plan.md` | 7-Phasen-Plan mit Checklisten |
| `testing_and_publishing.md` | Testen, Store, Gewerbe, Monetarisierung |
| `developer_experiences.md` | Erfahrungsberichte, Pitfalls, 18 Themen |

## Wichtige Garmin-Doku-Links

- SDK: https://developer.garmin.com/connect-iq/sdk/
- API Docs: https://developer.garmin.com/connect-iq/api-docs/
- AMOLED Guidelines: https://developer.garmin.com/connect-iq/user-experience-guidelines/watch-faces/
- Monkey C: https://developer.garmin.com/connect-iq/monkey-c/
- Build Config: https://developer.garmin.com/connect-iq/core-topics/build-configuration/
- On-Device Settings: https://developer.garmin.com/connect-iq/core-topics/editing-watch-faces-on-device/
