# Implementierungsplan: Windfall Watch Face

**Projekt:** "Windfall" / "Fallobst" — Clean, Apple-inspiriertes Watch Face für Garmin Descent G2
**Datum:** 2026-03-28

---

## Phase 0: Entwicklungsumgebung einrichten (Tag 1)

- [ ] Java JDK 17 installieren (`sudo apt install openjdk-17-jdk`)
- [ ] VS Code + Monkey C Extension installieren
- [ ] Connect IQ SDK Manager herunterladen (AppImage von GitHub oder offiziell)
- [ ] SDK installieren und Device File für Descent G2 laden
- [ ] Simulator testen mit einem Hello-World Watch Face
- [ ] Git-Repository initialisieren

---

## Phase 1: Projekt-Grundgerüst (Tag 1-2)

- [ ] Projekt aus Template erstellen (basierend auf `aurpelai/garmin-watchface-template`)
- [ ] `manifest.xml` konfigurieren:
  - App-ID generieren (UUID)
  - Zielgerät: Descent G2
  - Min API Level: 5.1
  - Typ: watchface
- [ ] Grundstruktur anlegen:
  ```
  windfall/
    source/
      WindfallApp.mc          # Entry Point
      WindfallView.mc         # WatchFace View
      WindfallDelegate.mc     # Touch/Button Handler
    resources/
      drawables/
      fonts/
      layouts/
      strings/
      settings/
  ```
- [ ] Basis `onUpdate()` implementieren (nur Uhrzeit anzeigen)
- [ ] Im Simulator testen

---

## Phase 2: Design-System definieren (Tag 2-3)

### Farbpalette (AMOLED-optimiert)
- **Hintergrund:** Reines Schwarz (#000000) — spart Akku auf AMOLED
- **Primärtext (Zeit):** Weiß (#FFFFFF)
- **Sekundärtext (Datum, Metriken):** Hellgrau (#A0A0A0)
- **Akzent 1:** Apfelgrün (#34C759) — für Aktivitätsdaten
- **Akzent 2:** Helles Blau (#007AFF) — für Tauch-/Wasserdaten
- **Akzent 3:** Orange (#FF9500) — für Warnungen/Herzfrequenz
- **Dezent:** Dunkelgrau (#333333) — für Trennlinien, Ringe

### Typografie
- Große, dünne Zeitanzeige (Custom Bitmap Font, SF-Pro-inspiriert)
- Kleinere Sans-Serif für Datum und Metriken
- Hierarchie: Zeit (groß) > Datum (mittel) > Komplikationen (klein)

### Layout (390x390 rund)
```
         ╭─────────────╮
        │   [Wochentag]  │
        │    [Datum]      │
        │                 │
        │    10:24        │  ← Zentral, große dünne Schrift
        │                 │
        │  ♥72  🔋85%    │  ← Komplikationen unten
        │   [Steps Ring]  │
         ╰─────────────╯
```

### AMOLED-Regeln beachten
- Always-On-Modus: Max 10% Pixel beleuchtet
- Burn-In-Protection: Elemente leicht verschieben
- Keine großen weißen Flächen
- Sekundenanzeige nur im aktiven Modus

---

## Phase 3: Kernfunktionen implementieren (Tag 3-6)

### 3.1 Zeitanzeige
- [ ] Custom Bitmap Font erstellen/finden (dünn, clean, Apple-Stil)
  - Tool: BMFont oder Garmin Font Editor
  - Alternativ: Zeichnen mit `dc.drawText()` und eingebautem Font
- [ ] 12h/24h Format aus Systemeinstellungen lesen
- [ ] Stunden:Minuten groß zentriert
- [ ] Sekunden nur im Active Mode (klein, dezent)

### 3.2 Datum
- [ ] Wochentag (kurz) + Datum
- [ ] Lokalisierung (DE/EN)
- [ ] Format: "Mo 28. Mär" / "Mon Mar 28"

### 3.3 Komplikationen (konfigurierbar)
- [ ] Herzfrequenz (mit farbigem Icon)
- [ ] Batterie (Prozent + dezenter Ring/Balken)
- [ ] Schritte (mit Fortschrittsring)
- [ ] Kalorien
- [ ] Höhe/Tiefe (relevant für Taucher)
- [ ] Wetter (Temperatur + Icon, falls API verfügbar)
- [ ] Sonnenauf-/untergang

### 3.4 Always-On Display (AOD)
- [ ] Vereinfachtes Layout: Nur Stunden:Minuten + minimale Info
- [ ] Max 10% Pixel beleuchtet
- [ ] Burn-In Offset (±3px jede Minute)
- [ ] `onEnterSleep()` / `onExitSleep()` implementieren

---

## Phase 4: Einstellungen (Tag 6-7)

- [ ] `settings.xml` definieren:
  - Farbschema (Default, Blau, Grün, Orange, Custom)
  - Angezeigte Komplikationen (an/aus pro Slot)
  - 12h/24h Override
  - Datumsformat
  - Sekundenanzeige an/aus
  - Always-On Komplexität (minimal/normal)
- [ ] On-Device Settings UI
- [ ] Garmin Connect Mobile Settings (properties.xml)
- [ ] Settings laden und in `onUpdate()` anwenden

---

## Phase 5: Optimierung (Tag 7-9)

### Performance
- [ ] Memory-Profiling im Simulator
- [ ] Ziel: < 28 KB Peak Memory (konservativ für breite Kompatibilität)
- [ ] Cached Drawables für statische Elemente
- [ ] Nur geänderte Bereiche neu zeichnen wo möglich
- [ ] Per-Second Updates nur wenn Sekunden sichtbar
- [ ] Per-Minute Updates im Normalfall

### Batterie
- [ ] AOD-Modus minimiert Updates auf 1x/Minute
- [ ] Sensor-Abfragen nur bei Bedarf
- [ ] Keine Animationen im AOD

### Kompatibilität
- [ ] Testen auf verschiedenen Auflösungen (falls Zielgerät erweitert wird)
- [ ] Fallbacks für nicht verfügbare Sensoren
- [ ] Graceful Degradation bei niedrigem API Level

---

## Phase 6: Testing (Tag 9-11)

- [ ] Simulator-Tests auf Descent G2
- [ ] Sideloading auf echtes Gerät (USB → GARMIN/Apps/)
- [ ] Alle Komplikationen einzeln testen
- [ ] AOD-Modus testen (Burn-In, Pixelzählung)
- [ ] Edge Cases:
  - Mitternacht-Übergang
  - Bluetooth-Verbindung verloren
  - Kein HR-Sensor aktiv
  - Batterie niedrig
  - DND-Modus
- [ ] Memory-Leak-Test (Langzeittest im Simulator)
- [ ] 12h vs 24h Format
- [ ] Verschiedene Sprachen

---

## Phase 7: Veröffentlichung (Tag 11-14)

- [ ] App-Icon erstellen (80x80 PNG)
- [ ] Screenshots erstellen (mind. 3-4)
- [ ] Store-Beschreibung schreiben (EN + DE)
- [ ] Garmin Developer Account erstellen (kostenlos)
- [ ] EEA-Identitätsverifizierung durchführen
- [ ] Beta-Version im Store hochladen
- [ ] Beta-Tester einladen
- [ ] Feedback einarbeiten
- [ ] Finale Version veröffentlichen

---

## Technische Referenzen

| Thema | Datei |
|-------|-------|
| Open Source Projekte & API | `research_open_source.md` |
| Entwicklungsumgebung Setup | `dev_environment_setup.md` |
| Testing & Publishing & Gewerbe | `testing_and_publishing.md` |
| Developer Erfahrungen | `developer_experiences.md` |

## Empfohlene Code-Basis

**Template:** `aurpelai/garmin-watchface-template` (MIT-Lizenz, MVC-Architektur)
**Referenz:** `warmsound/crystal-face` (AMOLED-Support, Performance-Patterns)
**Minimal-Referenz:** `dbcm/KISSFace` (Einfacher Einstieg)

## Kritische Punkte (aus Developer Experiences)

1. **Memory!** — Descent G2 hat mehr als ältere Geräte, aber trotzdem sparsam sein
2. **Simulator ≠ Gerät** — Immer auf echtem Gerät testen
3. **AMOLED-Regeln** — Garmin lehnt Apps ab, die Burn-In riskieren
4. **Keine Garmin-Design-Nachbauten** — Eigenes Design ist Pflicht (neue Regel seit Mai 2025)
5. **API-Fehler abfangen** — `has` prüfen bevor Methoden aufgerufen werden
