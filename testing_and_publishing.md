# Garmin Connect IQ: Testen, Veroeffentlichen & Rechtliches

> Stand: Maerz 2026 -- zusammengestellt aus offiziellen Garmin-Quellen, Foren und deutschen Rechtsquellen.

---

## 1. Testen von Connect IQ Apps und Watch Faces

### 1.1 Simulator (VSCode)

Die primaere Testumgebung ist der **Connect IQ Simulator**, der in die VSCode-Extension integriert ist.

**Voraussetzungen:**
- Visual Studio Code
- Java Runtime 8 oder hoeher
- Connect IQ SDK (ab Version 4.0.6+, aktuell wird SDK 7.x/8.x empfohlen)
- Monkey C VSCode Extension

**Ablauf:**
1. Extension installieren, VSCode neu starten
2. `Ctrl+Shift+P` -> "Monkey C: Verify Installation" ausfuehren
3. Play-Button in der Toolbar klicken -> Zielgeraet auswaehlen (z.B. "Instinct 3")
4. Der Simulator zeigt eine realistische Vorschau inkl. verschiedener Zeitformate, Backlight-Zustaende und Low-Battery-Simulation

**Einschraenkungen:**
- Der Simulator bildet nicht alle Hardware-Eigenheiten ab (z.B. exakte Display-Farben, Touch-Verhalten)
- Manche Sensordaten (HR, GPS) muessen manuell simuliert werden

> Quelle: [Garmin Developer - Reference Guides VSCode Extension](https://developer.garmin.com/connect-iq/reference-guides/visual-studio-code-extension/), [Getting Started Guide](https://www.ottorinobruni.com/getting-started-with-garmin-connect-iq-development-build-your-first-watch-face-with-monkey-c-and-vs-code/)

### 1.2 Sideloading auf ein physisches Geraet

Sideloading bedeutet, eine kompilierte `.prg`-Datei direkt auf die Uhr zu uebertragen -- ohne den Store.

**Ablauf:**
1. In VSCode: `Ctrl+Shift+P` -> "Monkey C: Build for Device" -> Zielgeraet auswaehlen
2. Die generierte `.prg`-Datei wird erstellt
3. Uhr per USB an den Computer anschliessen
4. Die `.prg`-Datei in den Ordner `GARMIN/Apps/` auf dem Geraet kopieren
5. Uhr sicher entfernen; nach Neustart ist die App verfuegbar

**Wichtige Hinweise:**
- Aktuelle Geraete **verstecken** `.prg`-Dateien nach der Installation -- sie werden in einen nicht zugaenglichen Speicherbereich verschoben. Die App funktioniert trotzdem
- Die App-ID in der `manifest.xml` muss eindeutig sein (nicht der Dateiname)
- Fuer Dateinamen gilt das 8.3-Schema
- Seit 2025 (System 8, Q2 QMR): Sideloads muessen mit **SDK 7.4.3 oder hoeher** gebaut sein
- Sideloaded Apps lassen sich ueber die Connect IQ Store App auf dem Geraet loeschen (Store App -> Installed -> App auswaehlen -> Loeschen)

**Unterschied Sideload vs. Release:**
- Sideload-Builds (`Build for Device`) enthalten Debug-Informationen
- Release-Builds (`.iq`-Datei fuer den Store, mit `-r` Flag) enthalten keine Debug-Infos

> Quellen: [Garmin Forum - Sideload PRG](https://forums.garmin.com/developer/connect-iq/f/discussion/367718/sideload-prg-file-no-longer-working), [Garmin Forum - Where do PRG files go](https://forums.garmin.com/developer/connect-iq/f/discussion/391547/where-do-the-app-prg-files-go-now-on-the-devices)

### 1.3 Beta-App-Testing ueber den Store

Garmin bietet ein **Beta-App-Feature** im Connect IQ Store:

- **Phase 1** (verfuegbar): App als "Beta" markieren -> App ist in einem speziellen Pending-Status, erscheint nicht oeffentlich, muss aber nicht mit "DO NOT APPROVE" beschriftet werden
- **Phase 2** (verfuegbar): Bestimmte Store-Nutzer per Whitelist freischalten, die die Beta-App herunterladen koennen
- Nach Upload kann man die eigene App als Vorschau herunterladen und testen, waehrend die Freigabe noch aussteht

> Quelle: [Garmin Developer - Beta Apps](https://developer.garmin.com/connect-iq/core-topics/beta-apps/)

---

## 2. Veroeffentlichung im Connect IQ Store

### 2.1 Developer Account erstellen

1. Registrierung unter [apps.garmin.com](https://apps.garmin.com) bzw. [Garmin CIQ Registration](https://www.garmin.com/en-US/forms/ciq-registration/)
2. **Kosten: Keine** -- es gibt keine Registrierungsgebuehren oder jaehrliche Kosten
3. Es wird ein Garmin-Konto benoetigt

### 2.2 Publishing-Prozess

1. **`.iq`-Datei erstellen**: In VSCode ueber "Monkey C: Export Project" eine Release-Build-Datei (`.iq`) generieren
2. **Upload**: Die `.iq`-Datei im [Garmin Developer Portal](https://apps.garmin.com) hochladen
3. **Validierung**: Garmin validiert automatisch das Binary
4. **Metadaten pflegen**:
   - App-Name und Beschreibung (mehrsprachig moeglich)
   - Screenshots (fuer verschiedene Geraetetypen)
   - Unterstuetzte Geraete auswaehlen
   - Kategorie und Tags setzen
   - Ggf. "Payment Required" Badge setzen
5. **Review einreichen**: Garmin prueft die App
6. **Freigabe**: Nach Approval erscheint die App im Store

### 2.3 App Review Guidelines

Garmin ist grundsaetzlich **permissiv** bei der Freigabe. Die meisten Apps werden genehmigt, sofern sie keine der folgenden Regeln verletzen:

**Inhaltliche Einschraenkungen:**
- Kein anstossiges/beleidigendes Material
- Keine DMCA-Verstoesse (Urheberrechtsverletzungen)
- Keine chinesische Nationalflagge (gesetzlich eingeschraenkt)

**Sicherheitskritische Bereiche (Ablehnung):**
- Tauch-Apps (Scuba, Freitauchen) -- nur fuer Descent-Geraete zulaessig
- Fallschirmspringen, Base-Jumping, Extrem-Flugsport
- Apps fuer Varia-Radar-Integration oder Unfallerkennung
- Medizin-Apps, die unter FDA-Regulierung fallen (muessen als "nur zu Bildungszwecken" gekennzeichnet sein)
- Luftfahrt-Apps erfordern einen spezifischen Disclaimer

**Branding-Regeln:**
- Kein Garmin-Logo, -Name oder -Marken ohne schriftliche Genehmigung
- Kompatibilitaetshinweise ("fuer Garmin-Geraete") sind erlaubt, sofern korrekt

**Watch-Face-Design-Policy (seit Mai 2025):**
- **Garmin-eigene Watch-Face-Designs duerfen NICHT nachgebaut werden**
- Betrifft insbesondere native Designs von Instinct 3, Forerunner 970/570 etc.
- Aeltere, bereits veroeffentlichte Klone werden nicht rueckwirkend entfernt
- Auch Kopien von Designs anderer Entwickler fuehren zur Ablehnung (auf Beschwerde hin)

> Quellen: [Garmin App Review Guidelines](https://developer.garmin.com/connect-iq/app-review-guidelines/), [Garmin Wiki - App Approval Exceptions](https://forums.garmin.com/developer/connect-iq/w/wiki/10/app-approval-exceptions), [Garmin Forum - Watch Face Design Policy](https://forums.garmin.com/developer/connect-iq/f/discussion/413172/policies-have-changed-regarding-the-use-of-original-garmin-watchface-designs-future-watchfaces-can-not-use-the-original-designs-anymore)

### 2.4 EEA/EU-Verfuegbarkeit und Developer Verification

Seit **Februar 2024** gelten besondere Anforderungen fuer die Sichtbarkeit von Apps im **Europaeischen Wirtschaftsraum (EWR/EEA)**, basierend auf dem **EU Digital Services Act (DSA)**.

**Fuer neue Entwickler:**
- Apps werden standardmaessig **ohne EEA-Verfuegbarkeit** veroeffentlicht
- Um Apps im EEA sichtbar zu machen, muss eine Identitaetsverifizierung durchgefuehrt werden

**Benoetigte Informationen (Privatperson):**
- Support-E-Mail-Adresse
- Stadt, Bundesland/Staat und Land des Wohnsitzes
- Kopie eines Ausweisdokuments (Personalausweis/Reisepass)

**Benoetigte Informationen (Unternehmen):**
- Firmenname
- Telefonnummer
- Support-E-Mail
- Vollstaendige Geschaeftsadresse
- DUNS-Nummer

**Nach Freigabe:** Entwicklerinformationen (E-Mail, Stadt, Land) werden **oeffentlich** neben den App-Listings angezeigt -- dies ist eine gesetzliche Pflicht.

**Trader-Verifizierung (zusaetzlich):**
- Wenn eine App **Zahlungen jeglicher Art** verlangt oder erbittet (inkl. Trinkgeld/Spenden), gilt der Entwickler als **"Trader"** im Sinne des DSA
- Trader muessen sich zusaetzlich verifizieren unter [apps.garmin.com/dsa](https://apps.garmin.com/dsa)
- **Ohne Trader-Verifizierung**: Bezahl-Apps werden aus dem Store **ausgeblendet**
- **Rein kostenlose Apps** ohne jegliche Zahlungsaufforderung sind von der Trader-Verifizierung **ausgenommen**

> Quellen: [Garmin Forum - Developer Verification](https://forums.garmin.com/developer/connect-iq/b/news-announcements/posts/developer-verification-begins-in-february), [Garmin Forum - EEA How-To](https://forums.garmin.com/developer/connect-iq/f/discussion/367635/garmin-approval-eea-how-to), [the5krunner - EU Apps](https://the5krunner.com/2024/02/15/garmin-connect-iq-apps-many-to-be-stopped-in-eu/)

---

## 3. Monetarisierung

### 3.1 Uebersicht der Optionen

| Methode | Garmin-Anteil | Besonderheiten |
|---|---|---|
| **Garmin Pay (nativ)** | 15% des Nettopreises | Garmin uebernimmt Kreditkartengebuehren; DST und Waehrungsumrechnung werden abgezogen |
| **Drittanbieter (z.B. KiezelPay)** | 0% an Garmin | Hoehere Gebuehren (~30%), aber 100% geht an den Drittanbieter-Prozessor; weiterhin erlaubt |
| **PayPal / eigene Loesung** | 0% an Garmin | Entwickler verwaltet alles selbst; PayPal-Gebuehren fallen an |
| **Spenden / Tips** | 0% an Garmin | Moeglich, macht den Entwickler aber zum "Trader" im Sinne des DSA |
| **Kostenlos** | -- | Kein Umsatz, keine Trader-Verifizierung noetig |

### 3.2 Garmin Pay Details

- Garmin nimmt **15%** (deutlich weniger als die ueblichen 30% bei anderen Plattformen)
- Garmin uebernimmt die Kreditkartenabwicklung
- Digitale Dienstleistungssteuern (DST) und Waehrungsumrechnung werden vom Auszahlungsbetrag abgezogen
- Preise werden aus vordefinierten **Price Points** gewaehlt (ab $0.99 / EUR-Aequivalent, haeufig $4.99 fuer Watch Faces)
- Merchant Onboarding erforderlich ueber das Developer Portal

### 3.3 Drittanbieter-Zahlungen

Garmin erlaubt weiterhin Drittanbieter-Zahlungssysteme:

- **KiezelPay**: Populaerster Drittanbieter fuer CIQ, nimmt ca. 30% Provision
- **TinyAppStore**: Neuerer Anbieter, speziell fuer Garmin-Apps
- **PayPal-Direktzahlung**: Entwickler verlinkt auf eigene Zahlungsseite

Wenn eine App Zahlung erfordert, muss sie als **"Payment Required"** markiert werden. Die Beschreibung muss klar angeben, welche Features kostenlos und welche kostenpflichtig sind.

### 3.4 Best Practices fuer Monetarisierung (laut Garmin)

- **Transparenz**: Monetarisierung von Anfang an offenlegen
- **Keine Ueberraschungen**: "Payment Required"-Badge setzen, wenn Kernfunktionen kostenpflichtig sind
- **Trial-Perioden**: Restlaufzeit klar kommunizieren
- **Watch Faces**: Keine Paywall auf dem Zifferblatt anzeigen; stattdessen ueber On-Device-Settings zur Zahlungsinfo fuehren
- **FAQ/Video**: Link zur Kaufanleitung oben in der App-Beschreibung platzieren

> Quellen: [Garmin - Monetization](https://developer.garmin.com/connect-iq/monetization/app-sales/), [Garmin Newsroom - Premium Purchases](https://www.garmin.com/en-US/newsroom/press-release/wearables-health/garmin-enables-premium-app-purchases-in-the-connect-iq-store-and-unveils-fun-new-watch-faces-and-apps/), [Garmin Forum - Monetization Tips](https://forums.garmin.com/developer/connect-iq/b/news-announcements/posts/tips-for-monetizing-your-apps)

---

## 4. Rechtliche Situation in Deutschland

### 4.1 Brauche ich ein Gewerbe fuer kostenlose Apps?

**Kurze Antwort: Nein.**

Wenn eine App rein als Hobby entwickelt und **kostenlos ohne jegliche Einnahmen** (keine Werbung, keine Spenden, keine In-App-Kaeufe) veroeffentlicht wird, liegt **keine Gewinnerzielungsabsicht** vor. Ohne Gewinnerzielungsabsicht besteht **keine Gewerbepflicht** nach § 14 GewO.

**Voraussetzungen fuer Gewerbefreiheit:**
- App ist komplett kostenlos
- Keine Werbung in der App
- Keine Spendenlinks oder Trinkgeld-Aufforderungen
- Keine In-App-Kaeufe
- Keine sonstige Monetarisierung

### 4.2 Brauche ich ein Gewerbe fuer kostenpflichtige Apps / Apps mit Einnahmen?

**Kurze Antwort: Ja, in der Regel schon.**

Nach § 14 Gewerbeordnung (GewO) ist ein Gewerbe anzumelden, wenn eine Taetigkeit:
- auf eigene Rechnung und Verantwortung ausgeueubt wird
- auf Dauer angelegt ist (nicht einmalig)
- mit **Gewinnerzielungsabsicht** verbunden ist

Sobald man Apps verkauft, Spenden sammelt oder Werbeeinnahmen erzielt, ist grundsaetzlich die Gewinnerzielungsabsicht gegeben -- selbst wenn es nur wenige Euro sind.

**App-Entwicklung ist in der Regel KEIN Freier Beruf** im steuerrechtlichen Sinne (anders als z.B. kuenstlerische Taetigkeit). Daher: Gewerbeanmeldung erforderlich.

### 4.3 Gewerbeanmeldung: Ablauf und Kosten

| Schritt | Details |
|---|---|
| **Wo** | Oertliches Gewerbeamt (oft auch online moeglich) |
| **Formular** | "Gewerbeanmeldung" (GewA 1) |
| **Kosten** | ca. 20-70 EUR (je nach Gemeinde) |
| **Wann** | **Vor** Beginn der Taetigkeit (vor erstem Verkauf) |
| **Dauer** | Gewerbeschein kommt oft sofort oder per Post |
| **Folge** | Finanzamt, IHK und ggf. Berufsgenossenschaft werden automatisch informiert |

### 4.4 Kleinunternehmerregelung (§ 19 UStG)

Wenn der jaehrliche Umsatz unter bestimmten Grenzen bleibt, kann die **Kleinunternehmerregelung** genutzt werden:

- **Grenze**: 22.000 EUR Umsatz im Vorjahr, 50.000 EUR im laufenden Jahr (Stand 2025/2026; die Grenze wurde 2025 auf 25.000 EUR angehoben)
- **Vorteil**: Keine Umsatzsteuer auf Rechnungen ausweisen und abfuehren
- **Nachteil**: Kein Vorsteuerabzug moeglich (z.B. fuer Hardware-Kaeufe)

Fuer die meisten Hobby-Entwickler mit geringen Einnahmen aus Watch Faces duerfte die Kleinunternehmerregelung ausreichen.

### 4.5 Steuerliche Pflichten

- **Einkommensteuer**: Einnahmen aus App-Verkaeufen sind als Einkuenfte aus Gewerbebetrieb in der Einkommensteuererklaerung anzugeben (Anlage G)
- **Umsatzsteuer**: Entfaellt bei Kleinunternehmerregelung; ansonsten 19% USt
- **Gewerbesteuer**: Freibetrag von 24.500 EUR Gewinn -- bei geringen Einnahmen aus Watch Faces faellt keine Gewerbesteuer an
- **Umsatzsteuer-IdNr.**: Empfehlenswert, wenn man im EU-Ausland taetig ist (Garmin sitzt in der Schweiz/USA)

**Achtung "Liebhaberei":** Wenn dauerhaft Verluste entstehen (z.B. teure Hardware, aber kaum Verkaeufe), kann das Finanzamt die Taetigkeit als Liebhaberei einstufen. Dann entfallen Steuervorteile, aber auch die Steuerpflicht auf diese Einnahmen.

### 4.6 Spenden-/Trinkgeld-Modell

Ein beliebtes Modell: App kostenlos anbieten, aber um freiwillige Spenden bitten.

**Rechtliche Einordnung:**
- Auch Spendeneinnahmen sind **Betriebseinnahmen** und steuerpflichtig
- Regelmaessige Spendeneinnahmen begruenden **Gewinnerzielungsabsicht** -> Gewerbeanmeldung noetig
- Im Sinne des EU DSA gilt man als **Trader**, sobald man Spenden/Tips erbittet
- Man muss sich dann bei Garmin als Trader verifizieren

**Fazit Spenden-Modell:** Juristisch kaum anders als ein kostenpflichtiges Modell. Sobald regelmaessig Geld fliesst, braucht man ein Gewerbe.

### 4.7 Zusammenfassung: Gewerbe ja oder nein?

| Szenario | Gewerbe noetig? | Trader-Verifizierung (Garmin/DSA)? |
|---|---|---|
| Komplett kostenlose App, kein Geld | **Nein** | **Nein** |
| Kostenlose App mit Spendenlink | **Ja** (bei regelmaessigen Einnahmen) | **Ja** |
| Kostenpflichtige App (Garmin Pay) | **Ja** | **Ja** |
| Kostenpflichtige App (KiezelPay/PayPal) | **Ja** | **Ja** |
| Einmalige Gelegenheit, kleiner Betrag | **Eher nein** (Einzelfall) | Kommt auf die Darstellung an |

### 4.8 Garmin-spezifisch: Privatperson vs. Unternehmen

Garmin unterscheidet bei der Registrierung zwischen **Individual** und **Company**:

- **Individual Developer**: Registrierung als Privatperson ist moeglich und ausreichend
- Es wird **kein Gewerbeschein** oder Handelsregistereintrag von Garmin verlangt
- Fuer die EEA-Verifizierung als Privatperson reichen: E-Mail, Wohnort, Ausweis
- Fuer die Trader-Verifizierung: zusaetzliche Angaben erforderlich

**Garmin selbst verlangt also kein Gewerbe** -- die Gewerbepflicht ergibt sich rein aus deutschem Recht bei Gewinnerzielungsabsicht.

> Quellen: [Existenzgruendungsportal - App verkaufen Gewerbe](https://www.existenzgruendungsportal.de/Redaktion/DE/BMWK-Infopool/Antworten/Gruendungsplanung/Gewerbe-Genehmigungen/Dienstleistung/App-ueber-Apple-Store-verkaufen-Gewerbe-anmelden), [Existenzgruendungsportal - Kleinunternehmen](https://www.existenzgruendungsportal.de/Redaktion/DE/BMWK-Infopool/Antworten/Steuern/Kleinunternehmer/App-entwickelt-Kleinunternehmen-anmelden), [Taxfix - Gewerbe anmelden 2026](https://taxfix.de/ratgeber/selbststaendige/gewerbe-anmelden/), [Anwalt-KG - App entwickeln und betreiben](https://anwalt-kg.de/unternehmensrecht/app-entwickeln/)

---

## 5. Praktischer Ablaufplan

### Szenario A: Kostenlose Watch Face veroeffentlichen (kein Geld)

1. SDK installieren, Watch Face entwickeln und im Simulator testen
2. Auf physischem Geraet per Sideloading testen
3. Garmin Developer Account erstellen (kostenlos)
4. EEA-Verifizierung durchfuehren (Ausweis + Wohnort), damit die App in Europa sichtbar ist
5. `.iq`-Datei exportieren und im Developer Portal hochladen
6. Screenshots und Beschreibung hinzufuegen
7. Zur Review einreichen
8. **Kein Gewerbe noetig, keine Trader-Verifizierung noetig**

### Szenario B: Watch Face mit Garmin Pay verkaufen

1. Schritte 1-4 wie oben
2. Merchant Onboarding bei Garmin durchfuehren
3. Trader-Verifizierung abschliessen (DSA-Pflicht)
4. **Gewerbe in Deutschland anmelden** (ca. 20-70 EUR)
5. Steuerliche Erfassung beim Finanzamt (Kleinunternehmerregelung waehlen falls gewuenscht)
6. App hochladen, "Payment Required" markieren, Preispunkt waehlen
7. Zur Review einreichen
8. USt-IdNr. beantragen (empfohlen)

### Szenario C: Kostenlose Watch Face mit Spenden/Tips

1. Schritte 1-4 wie Szenario A
2. Trader-Verifizierung abschliessen (wegen Spendenlinks)
3. **Gewerbe anmelden** (sobald regelmaessige Einnahmen zu erwarten sind)
4. Steuerliche Erfassung beim Finanzamt
5. App hochladen, in Beschreibung klar angeben welche Features kostenlos sind
6. Spendenlink in App-Beschreibung oder Settings platzieren

---

## 6. Wichtige Links

| Ressource | URL |
|---|---|
| Connect IQ SDK Download | https://developer.garmin.com/connect-iq/sdk/ |
| Developer Portal / App Upload | https://apps.garmin.com |
| App Review Guidelines | https://developer.garmin.com/connect-iq/app-review-guidelines/ |
| Publishing to the Store | https://developer.garmin.com/connect-iq/core-topics/publishing-to-the-store/ |
| Beta Apps | https://developer.garmin.com/connect-iq/core-topics/beta-apps/ |
| Monetization / App Sales | https://developer.garmin.com/connect-iq/monetization/app-sales/ |
| Price Points | https://developer.garmin.com/connect-iq/monetization/price-points/ |
| DSA Trader Verification | https://apps.garmin.com/dsa |
| Developer Registration | https://www.garmin.com/en-US/forms/ciq-registration/ |
| VSCode Extension Guide | https://developer.garmin.com/connect-iq/reference-guides/visual-studio-code-extension/ |
| Debugging / Testing | https://developer.garmin.com/connect-iq/core-topics/debugging/ |
| Existenzgruendungsportal (DE) | https://www.existenzgruendungsportal.de |
| Gewerbe anmelden (Taxfix) | https://taxfix.de/ratgeber/selbststaendige/gewerbe-anmelden/ |

---

*Hinweis: Diese Zusammenstellung ersetzt keine Rechts- oder Steuerberatung. Fuer verbindliche Auskuenfte zum Thema Gewerbeanmeldung und Steuern wende dich an einen Steuerberater, das zustaendige Finanzamt oder die IHK.*
