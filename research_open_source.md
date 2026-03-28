# Research: Open Source Garmin Watch Face Projects

**Projekt:** Windfall ("Fallobst") Watch Face for Garmin Descent G2
**Datum:** 2026-03-28

---

## 1. Garmin Descent G2 -- Technische Spezifikationen

| Eigenschaft | Wert |
|---|---|
| Display | 1.2" AMOLED, Touchscreen |
| Aufloesung | 390 x 390 Pixel |
| Form | Rund |
| Connect IQ API Level | 5.1 |
| Glas | Saphirkristall |
| Sensoren | GPS/GLONASS/Galileo, Elevate 4 HR, SpO2, Barometer, Kompass, Beschleunigungssensor, Thermometer, Gyroskop, Tiefensensor |
| NFC | Garmin Pay |
| Akku (Smartwatch) | bis zu 10 Tage |
| Akku (Dive Mode) | ca. 27 Stunden (getestet: bis 39 Stunden) |
| Gehaeuse | Recycelter Ozean-Kunststoff |
| Besonderheit | Tauchcomputer mit Multi-Gas-Unterstuetzung (Nitrox, Trimix, CCR) |

**Wichtig fuer die Entwicklung:**
- AMOLED erfordert Burn-In-Protection im Always-On-Modus
- 390x390 ist eine hohe Aufloesung -- erfordert hochaufloesende Assets
- API Level 5.1 unterstuetzt Complications und moderne Features
- Touchscreen-Eingabe verfuegbar

---

## 2. Open Source Garmin Watch Face Projekte

### 2.1 Crystal Face (Top-Empfehlung als Referenz)

- **GitHub:** https://github.com/warmsound/crystal-face
- **Lizenz:** Open Source
- **Commits:** 712+
- **Beschreibung:** Feature-reiches Watch Face mit grosser Zeitanzeige, konfigurierbaren Datenfeldern, Indikatoren und Ziel-Metern
- **Staerken:**
  - Unterstuetzt AMOLED-Geraete (inkl. vivoactive 6, fenix 8)
  - Palette-restricted Back Buffer fuer optimale Zeichenperformance
  - Umfangreiche Geraete-Unterstuetzung (208x208 bis 454x454)
  - 25+ Sprachen lokalisiert
  - On-Device-Einstellungen
  - OpenWeatherMap-Integration
  - Optimierte Per-Second-Updates (~5ms)
- **Architektur:**
  - `/source` -- Kernlogik
  - `/resources` -- Geraete-spezifische Ressourcen
  - `/resources-[resolution]` -- Aufloesungsspezifische Assets
  - `/always-on-source` -- AMOLED Always-On Implementierung
- **Relevanz fuer Windfall:** Hervorragende Referenz fuer AMOLED-Optimierung, Performance-Techniken und Multi-Device-Support. Die Always-On-Implementierung ist direkt uebertragbar.

### 2.2 Garmin Watchface Template (Top-Empfehlung als Startpunkt)

- **GitHub:** https://github.com/aurpelai/garmin-watchface-template
- **Lizenz:** MIT
- **Commits:** 125
- **Beschreibung:** Einfaches Template zum Kickstart eines Watch-Face-Projekts
- **Staerken:**
  - MVC-Architektur (Model/View/Controller)
  - Custom Update-Intervalle pro Komponente
  - On-Device Settings Management
  - System 4 (CIQ API Level 3.2.0+)
- **Projektstruktur:**
  - `/source/components/` -- View-Komponenten
  - `/source/controllers/` -- Controller-Logik
  - `manifest.xml` -- App-Konfiguration
  - `monkey.jungle` -- Build-Konfiguration
- **Relevanz fuer Windfall:** Ideales Starttemplate mit sauberer Architektur. MVC-Pattern erleichtert die Wartung und Erweiterung.

### 2.3 KISSFace

- **GitHub:** https://github.com/dbcm/KISSFace
- **Beschreibung:** "Keep It Simple, Stupid" Watch Face -- minimalistisches Design
- **Relevanz fuer Windfall:** Gute Referenz fuer minimalistisches Design-Paradigma.

### 2.4 SnapshotWatch

- **GitHub:** https://github.com/darrencroton/SnapshotWatch
- **Beschreibung:** Elegantes Analog-Watch-Face mit HR-Graph
- **Staerken:** Saubere Darstellung von Tageswerten (HR, Steps, Sunrise/Sunset)
- **Relevanz fuer Windfall:** Referenz fuer elegante Datenvisualisierung.

### 2.5 Connect IQ 101 Tutorial

- **GitHub:** https://github.com/AndrewKhassapov/connect-iq
- **Beschreibung:** "Creating a Garmin watch-face 101" -- Schritt-fuer-Schritt-Tutorial
- **Relevanz fuer Windfall:** Gute Lernressource fuer Grundlagen, aktualisiert Oktober 2024.

### 2.6 Kudos

- **GitHub:** https://github.com/Peterdedecker/kudos
- **Beschreibung:** Watch Face inspiriert von Crystal mit font-basierten Metern
- **Relevanz fuer Windfall:** Zeigt alternative Ansaetze fuer Meter-Darstellung.

### 2.7 FaceOfFenix

- **GitHub:** https://github.com/woytekm/FaceOfFenix
- **Beschreibung:** Watch Face fuer 240x240 und 280x280 runde Screens
- **Relevanz fuer Windfall:** Referenz fuer saubere Fenix-kompatible Designs.

### 2.8 Digital5

- **GitHub:** https://github.com/HanSolo/digital5
- **Beschreibung:** Digitales Watch Face fuer fenix 5x mit LCD-Hintergrund
- **Relevanz fuer Windfall:** Referenz fuer digitale Zeitanzeige-Stile.

### 2.9 BYOD-Watchface

- **GitHub:** https://github.com/NickSteen/BYOD-Watchface
- **Beschreibung:** Vollstaendig anpassbares digitales Watch Face mit sechs frei zuweisbaren Feldern
- **Relevanz fuer Windfall:** Referenz fuer konfigurierbares Layout-System.

### 2.10 as-garmin-watch-face

- **GitHub:** https://github.com/asodja/as-garmin-watch-face
- **Beschreibung:** Persoenliches Watch Face mit modernem Design
- **Relevanz fuer Windfall:** Referenz fuer individuellen Designansatz.

---

## 3. Connect IQ API -- Verfuegbare Features fuer Watch Faces

### 3.1 Kernmodule (Toybox)

| Modul | Funktion |
|---|---|
| `Toybox.WatchUi.WatchFace` | Basis-Klasse fuer Watch Faces mit Lifecycle-Management |
| `Toybox.Graphics.Dc` | Device Context zum Zeichnen (Text, Formen, Bilder) |
| `Toybox.System` | Systeminfos (Uhrzeit, Batterie, Bluetooth-Status) |
| `Toybox.ActivityMonitor` | Schritte, Kalorien, Floors, HR-History |
| `Toybox.SensorHistory` | Sensor-Datenhistorie (HR, Temperatur, Elevation, Body Battery) |
| `Toybox.Sensor` | Echtzeit-Sensordaten |
| `Toybox.Complications` | Einheitliche Schnittstelle fuer Metriken (ab CIQ 4.2.0) |
| `Toybox.Weather` | Wetterdaten |
| `Toybox.Time` | Zeit- und Datum-Funktionen |
| `Toybox.Application.Properties` | Persistente Einstellungen |

### 3.2 Watch Face Lifecycle

```
onLayout()          --> Initiale Ressourcen laden
onShow()            --> View wird sichtbar
onUpdate(dc)        --> Display aktualisieren (jede Sekunde im High-Power, jede Minute im Low-Power)
onPartialUpdate(dc) --> Teilweises Update (nur MIP-Displays, nicht AMOLED)
onEnterSleep()      --> Wechsel zu Low-Power-Modus
onExitSleep()       --> Wechsel zu High-Power-Modus
```

### 3.3 AMOLED-Spezifische Regeln

- **10%-Regel:** Im Sleep-Modus duerfen maximal 10% der Pixel leuchten, sonst wird das Display schwarz
- **Burn-In-Protection:** `Sys.getDeviceSettings().requiresBurnInProtection` pruefen
  - Duenne Schriftarten verwenden
  - Position jede Minute leicht verschieben
  - Keine statischen Tick-Markierungen
- **Kein `onPartialUpdate()`** auf AMOLED-Geraeten
- **Schwarz = Aus:** Jeder leuchtende Pixel verbraucht Strom; moeglichst viel schwarz
- **CIQ 7+:** Helligkeitsbasierte Regel erlaubt mehr Pixel, solange Gesamthelligkeit unter 10%

### 3.4 Verfuegbare Datenfelder

**Gesundheit & Fitness:**
- Herzfrequenz (live, historisch, 5-Sekunden-Durchschnitt)
- Schritte (aktuell / Ziel)
- Kalorien verbrannt
- Floors Climbed
- Active Minutes (wochenweise)
- Body Battery
- SpO2 (Blutsauerstoff)
- Stress Level

**System:**
- Batterie (Prozent)
- Bluetooth-Status
- Benachrichtigungen (Anzahl)
- Alarme
- Do-Not-Disturb

**Umgebung:**
- Temperatur
- Barometrischer Druck
- Hoehe
- Sonnenauf-/untergang
- Wetterdaten
- GPS-Position

**Tauchen (Descent-spezifisch):**
- Tiefe (ueber Tiefensensor)
- Wassertemperatur

---

## 4. Monkey C Programmiersprache

### 4.1 Ueberblick

- Objektorientierte, dynamisch typisierte Sprache
- Syntaxmix aus Java, JavaScript, Python, PHP, Ruby
- Duck-Typing: Kein expliziter Typzwang
- Alles ist ein Objekt (keine Primitiven)

### 4.2 Grundlegende Syntax

```monkey-c
// Variablen
var name = "Windfall";
const VERSION = "1.0.0";

// Typen: Integer, Float, Long, Double, Char, String, Boolean, Object

// Import
using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;

// Klasse mit Vererbung
class WindfallView extends WatchUi.WatchFace {
    function initialize() {
        WatchFace.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$", [
            clockTime.hour.format("%02d"),
            clockTime.min.format("%02d")
        ]);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2,
            Graphics.FONT_NUMBER_THAI_HOT,
            timeString,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}
```

### 4.3 Besonderheiten

- `using` statt `import`
- `function` statt `method`/`def`
- `extends` fuer Vererbung
- Alle Funktionen geben einen Wert zurueck (auch ohne explizites `return`)
- Typ-Annotationen optional aber empfohlen (seit CIQ 4.0)
- Ressourcen ueber `Rez`-Namespace (z.B. `Rez.Drawables.Logo`)

---

## 5. Connect IQ Projektstruktur

```
windfall/
  |-- manifest.xml              # App-Konfiguration, Geraete, Berechtigungen
  |-- monkey.jungle             # Build-Konfiguration
  |-- .vscode/                  # VS Code Einstellungen
  |-- source/
  |   |-- WindfallApp.mc        # Application-Klasse (Entry Point)
  |   |-- WindfallView.mc       # WatchFace View (onUpdate, Zeichenlogik)
  |   |-- WindfallDelegate.mc   # Input-Handler (optional)
  |   |-- components/           # Wiederverwendbare UI-Komponenten
  |   +-- controllers/          # Daten-Controller (HR, Battery, etc.)
  |-- resources/
  |   |-- drawables/
  |   |   |-- drawables.xml     # Bild-Referenzen
  |   |   +-- launcher_icon.png # App-Icon
  |   |-- fonts/                # Custom Bitmap-Fonts
  |   |-- layouts/
  |   |   +-- layout.xml        # UI-Layout-Definition
  |   |-- strings/
  |   |   +-- strings.xml       # Lokalisierbare Strings
  |   +-- settings/
  |       +-- settings.xml      # On-Device Settings Definition
  |-- resources-ger/            # Deutsche Lokalisierung
  +-- bin/                      # Build-Output
```

### 5.1 manifest.xml

Definiert:
- App-ID (UUID)
- App-Name und Typ (watchface)
- Min/Max API Level
- Unterstuetzte Geraete
- Berechtigungen (z.B. Sensor-Zugriff)

### 5.2 monkey.jungle

Build-Konfigurationsdatei (DSL):
- Verwaltet Geraete-spezifische Builds
- Konfiguriert Ressourcen-Pfade pro Device
- Lazy Evaluation von Properties

---

## 6. Empfohlene Vorgehensweise fuer "Windfall"

### Basis-Template: `aurpelai/garmin-watchface-template`

**Gruende:**
1. MIT-Lizenz erlaubt kommerzielle Nutzung
2. MVC-Architektur passt zu einem sauberen, wartbaren Design
3. Custom Update-Intervalle sparen Batterie
4. On-Device Settings bereits integriert
5. API Level 3.2.0+ ist kompatibel mit Descent G2 (API 5.1)

### Referenz-Implementierung: `warmsound/crystal-face`

**Zu uebernehmende Konzepte:**
1. AMOLED Always-On Implementierung
2. Palette-restricted Back Buffer Technik
3. Geraete-spezifische Ressourcen-Organisation
4. Performance-Optimierungen (Cached Drawables, minimale Updates)
5. Lokalisierungs-Pattern

### Design-Inspiration: Apple Watch (Clean/Minimal)

**Ziel-Aesthetik:**
- Grosse, gut lesbare Zeitanzeige mit duenner Schrift (SF Pro / Helvetica Neue Stil)
- Minimale Komplikationen mit viel Whitespace (hier: Blackspace wegen AMOLED)
- Dezente Farbakzente auf schwarzem Hintergrund
- Sanfte Rundungen und moderne Typografie
- Hierarchische Informationsdarstellung (Zeit > Datum > Metriken)

---

## 7. Quellen und Links

### Offizielle Garmin-Dokumentation
- [Connect IQ SDK](https://developer.garmin.com/connect-iq/)
- [Connect IQ Basics / Getting Started](https://developer.garmin.com/connect-iq/connect-iq-basics/getting-started/)
- [Monkey C Referenz](https://developer.garmin.com/connect-iq/monkey-c/)
- [API-Dokumentation (Toybox)](https://developer.garmin.com/connect-iq/api-docs/)
- [WatchFace API](https://developer.garmin.com/connect-iq/api-docs/Toybox/WatchUi/WatchFace.html)
- [Graphics.Dc API](https://developer.garmin.com/connect-iq/api-docs/Toybox/Graphics/Dc.html)
- [Complications](https://developer.garmin.com/connect-iq/core-topics/complications/)
- [AMOLED Watch Face Guidelines](https://developer.garmin.com/connect-iq/user-experience-guidelines/watch-faces/)
- [AMOLED FAQ](https://developer.garmin.com/connect-iq/connect-iq-faq/how-do-i-make-a-watch-face-for-amoled-products/)
- [Compatible Devices](https://developer.garmin.com/connect-iq/compatible-devices/)
- [SDK Download](https://developer.garmin.com/connect-iq/sdk/)
- [Command Line Setup](https://developer.garmin.com/connect-iq/reference-guides/monkey-c-command-line-setup/)
- [VS Code Extension](https://developer.garmin.com/connect-iq/reference-guides/visual-studio-code-extension/)
- [Build Configuration (monkey.jungle)](https://developer.garmin.com/connect-iq/core-topics/build-configuration/)
- [Layouts](https://developer.garmin.com/connect-iq/core-topics/layouts/)
- [Watch Face Configuration (On-Device Editing)](https://developer.garmin.com/connect-iq/core-topics/editing-watch-faces-on-device/)
- [Compiler Options](https://developer.garmin.com/connect-iq/monkey-c/compiler-options/)

### GitHub-Projekte
- [Crystal Face](https://github.com/warmsound/crystal-face) -- Feature-reiches Watch Face mit AMOLED-Support
- [Garmin Watchface Template](https://github.com/aurpelai/garmin-watchface-template) -- MVC-Template (MIT)
- [KISSFace](https://github.com/dbcm/KISSFace) -- Minimalistisches Watch Face
- [SnapshotWatch](https://github.com/darrencroton/SnapshotWatch) -- Elegantes Analog-Watch-Face
- [Connect IQ 101](https://github.com/AndrewKhassapov/connect-iq) -- Tutorial-Projekt
- [Kudos](https://github.com/Peterdedecker/kudos) -- Watch Face mit Font-Metern
- [FaceOfFenix](https://github.com/woytekm/FaceOfFenix) -- Fenix-inspiriertes Watch Face
- [Digital5](https://github.com/HanSolo/digital5) -- Digitales Watch Face
- [BYOD-Watchface](https://github.com/NickSteen/BYOD-Watchface) -- Konfigurierbares Watch Face
- [as-garmin-watch-face](https://github.com/asodja/as-garmin-watch-face) -- Modernes persoenliches Watch Face

### Linux-Entwicklungstools
- [Connect IQ SDK Manager AppImage](https://github.com/pcolby/connectiq-sdk-manager) -- SDK Manager fuer moderne Linux-Distributionen
- [connect-iq-sdk-manager-cli](https://github.com/lindell/connect-iq-sdk-manager-cli) -- CLI-Tool fuer SDK-Management
- [connectiq-sdk-docker](https://github.com/waterkip/connectiq-sdk-docker) -- Docker-basierte Entwicklungsumgebung
- [garmin-connectiq-linux](https://github.com/BodyFatControl/garmin-connectiq-linux) -- Linux-Anleitungen

### Tutorials und Artikel
- [Monkey C Fundamentals (Medium)](https://medium.com/@earel329/garmin-iq-and-monkey-c-fundamentals-ffe83eebb3fc)
- [Getting Started with VS Code (Ottorino Bruni)](https://www.ottorinobruni.com/getting-started-with-garmin-connect-iq-development-build-your-first-watch-face-with-monkey-c-and-vs-code/)
- [Develop a Garmin Watch Face (Kai Hao)](https://kaihao.dev/posts/Develop-a-Garmin-watch-face)
- [Hello Monkey C (Dan Siwiec)](https://danoncoding.com/creating-a-garmin-connect-iq-application-part-1-hello-monkey-c-813eff5076e6)
- [Design your own Garmin watch face (Medium)](https://medium.com/@ericbt/design-your-own-garmin-watch-face-21d004d38f99)
- [Build your own Garmin Watchface (Herold Solutions)](https://herold.solutions/blog/2024-08-22-build-your-own-garmin-watchface)
- [Ubuntu SDK Installation (James E Phelps)](https://jamesephelps.com/2023/02/07/installing-garmin-sdk-in-ubuntu-22-04/)
- [Ubuntu 20 SDK Installation (Monzool)](https://monzool.net/blog/2021/10/22/installing-garmin-connect-iq-sdk-on-ubuntu-20/)

### Garmin Forum Threads
- [Open Source Watch Face Template](https://forums.garmin.com/developer/connect-iq/f/discussion/220320/open-source-watch-face-template)
- [Garmin SDK under Linux](https://forums.garmin.com/developer/connect-iq/f/discussion/196895/garmin-sdk-under-linux)
- [AMOLED Always-On Behaviour](https://forums.garmin.com/developer/connect-iq/f/discussion/322419/always-on-display-sleep-mode-behaviour-and-rules-on-newer-amoled-watches)
- [SDK & VS Code Problems with Linux](https://forums.garmin.com/developer/connect-iq/f/discussion/399834/garmin-sdk-vs-code-problems-with-linux)
