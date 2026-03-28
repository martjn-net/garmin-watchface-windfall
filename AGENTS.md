# Windfall Watch Face — Garmin Descent G2

## Regeln

- **Niemals** den Namen "Apple" in Code, Docs, Beschreibungen oder Commit-Messages verwenden. Das Design ist "modern-minimalistisch" — keine Markenreferenzen.
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

## Entwicklungsumgebung

- Java JDK 17 (Fallback: JDK 11 bei Kompatibilitätsproblemen)
- VS Code + Monkey C Extension
- Connect IQ SDK 7.x+
- Linux: `connect-iq-sdk-manager-cli` oder AppImage von `pcolby/connectiq-sdk-manager`
- Build: `monkey.jungle` Konfiguration
- Test: Simulator in VS Code, Sideload per USB → `GARMIN/Apps/`

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
