# Entwicklungsumgebung: Garmin Connect IQ auf Linux

**Projekt:** Windfall Watch Face fuer Garmin Descent G2
**Datum:** 2026-03-28

---

## Voraussetzungen

| Komponente | Version | Zweck |
|---|---|---|
| Java JDK/JRE | 8 oder hoeher (empfohlen: 17 LTS) | Runtime fuer SDK-Tools |
| VS Code | Aktuell | IDE mit Monkey C Extension |
| Connect IQ SDK | 7.x+ (aktuellste Version) | Compiler, Simulator, Device Files |
| Monkey C Extension | Aktuell (von Garmin) | Syntax-Highlighting, Build, Debug |
| Git | Aktuell | Versionskontrolle |

---

## Schritt 1: Java JDK installieren

> **Hinweis:** Einige Entwickler berichten von Kompatibilitaetsproblemen mit Java 12+.
> Falls Probleme auftreten, auf OpenJDK 11 LTS zurueckwechseln.

```bash
# OpenJDK 17 LTS installieren (Standard)
# Bei Problemen: openjdk-11-jdk als Fallback
sudo apt update
sudo apt install openjdk-17-jdk openjdk-17-jre

# Version pruefen
java -version
javac -version

# JAVA_HOME setzen (in ~/.bashrc oder ~/.zshrc)
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
```

---

## Schritt 2: VS Code installieren

Falls noch nicht installiert:

```bash
# Via Snap (einfachste Methode)
sudo snap install code --classic

# Oder via APT Repository
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
sudo apt update
sudo apt install code
```

---

## Schritt 3: Connect IQ SDK installieren

### Option A: CLI SDK Manager (empfohlen fuer Linux)

Der `connect-iq-sdk-manager-cli` ist die zuverlaessigste Methode auf Linux:

```bash
# Installation via Homebrew (falls verfuegbar)
brew install lindell/connect-iq-sdk-manager-cli/connect-iq-sdk-manager

# Oder via curl-Installer
curl -s https://raw.githubusercontent.com/lindell/connect-iq-sdk-manager-cli/master/install.sh | sh

# Oder via Go
go install github.com/lindell/connect-iq-sdk-manager-cli@latest
```

**SDK herunterladen und einrichten:**

```bash
# Lizenzvereinbarung anzeigen und akzeptieren
connect-iq-sdk-manager agreement view
connect-iq-sdk-manager agreement accept

# SDK-Version installieren (aktuelle Version waehlen)
connect-iq-sdk-manager sdk set 7.3.1

# Device-Dateien fuer Descent G2 herunterladen
# (spaeter, wenn manifest.xml existiert)
connect-iq-sdk-manager device download --manifest=windfall/manifest.xml
```

### Option B: AppImage SDK Manager

Fuer Systeme mit Ubuntu 24.04+ wo die offizielle GUI nicht laeuft:

```bash
# AppImage herunterladen
curl -Ls https://raw.githubusercontent.com/pcolby/connectiq-sdk-manager/main/install.sh | bash -r

# Oder manuell von GitHub Releases herunterladen:
# https://github.com/pcolby/connectiq-sdk-manager/releases

# AppImage ausfuehrbar machen und starten
chmod +x ConnectIQ-SDK-Manager-*.AppImage
./ConnectIQ-SDK-Manager-*.AppImage
```

**Hinweis:** Die offizielle GUI des SDK Managers hat eine Abhaengigkeit zu `webkit2gtk-4.0`, die auf modernen Ubuntu-Versionen (24.04+) nicht mehr verfuegbar ist. Der AppImage-Wrapper loest dieses Problem.

### Option C: Manueller Download

```bash
# SDK von der offiziellen Seite herunterladen
# https://developer.garmin.com/connect-iq/sdk/

# ZIP entpacken
mkdir -p ~/connectiq-sdk
unzip connectiq-sdkmanager-linux-*.zip -d ~/connectiq-sdk/

# Ausfuehrbar machen
chmod +x ~/connectiq-sdk/bin/sdkmanager
chmod +x ~/connectiq-sdk/bin/monkeyc
chmod +x ~/connectiq-sdk/bin/monkeydo
chmod +x ~/connectiq-sdk/bin/connectiq

# GUI starten (erfordert webkit2gtk-4.0)
~/connectiq-sdk/bin/sdkmanager
```

### Option D: Docker-Umgebung

Fuer maximale Reproduzierbarkeit:

```bash
# Docker-basierte Entwicklungsumgebung
# https://github.com/waterkip/connectiq-sdk-docker
git clone https://github.com/waterkip/connectiq-sdk-docker.git
cd connectiq-sdk-docker
# Anweisungen im README folgen
```

---

## Schritt 4: Umgebungsvariablen setzen

In `~/.bashrc` oder `~/.zshrc`:

```bash
# Connect IQ SDK Pfade
export CIQ_HOME=$HOME/.Garmin/ConnectIQ
export SDKROOT=$CIQ_HOME/Sdks/connectiq-sdk-lin-7.3.1-2025-01-15-abc1234  # Pfad anpassen!
export PATH=$SDKROOT/bin:$PATH

# Alternative: Falls SDK manuell installiert
# export SDKROOT=$HOME/connectiq-sdk
# export PATH=$SDKROOT/bin:$PATH
```

```bash
# Shell neu laden
source ~/.bashrc
```

---

## Schritt 5: Monkey C VS Code Extension installieren

```bash
# Extension ueber die Kommandozeile installieren
code --install-extension garmin.monkey-c
```

**Oder in VS Code:**
1. Extensions-Panel oeffnen (`Ctrl+Shift+X`)
2. Nach "Monkey C" suchen
3. Die Extension von **Garmin** installieren

**Anforderungen der Extension:**
- VS Code
- Java Runtime 8+
- Connect IQ SDK 4.0.6+

---

## Schritt 6: Developer Key generieren

Jede Connect IQ App muss mit einem RSA-4096-Schluessel signiert werden:

**Via VS Code:**
1. Command Palette oeffnen (`Ctrl+Shift+P`)
2. "Monkey C: Generate a Developer Key" waehlen
3. Speicherort waehlen (z.B. `~/.garmin/developer_key.der`)

**Via Kommandozeile:**
```bash
# RSA-4096 Schluessel generieren
openssl genrsa -out developer_key.pem 4096
openssl pkcs8 -topk8 -inform PEM -outform DER -in developer_key.pem -out developer_key.der -nocrypt

# Sicher aufbewahren!
mkdir -p ~/.garmin
mv developer_key.der ~/.garmin/
mv developer_key.pem ~/.garmin/
chmod 600 ~/.garmin/developer_key.*
```

**WICHTIG:** Den Developer Key sicher aufbewahren und Backup erstellen! Ohne diesen Key koennen veroeffentlichte Apps nicht aktualisiert werden.

---

## Schritt 7: Neues Projekt erstellen

**Via VS Code:**
1. Command Palette (`Ctrl+Shift+P`)
2. "Monkey C: New Project" waehlen
3. Projekttyp: **Watch Face**
4. Template: **Simple**
5. API-Version: **5.1.0** (fuer Descent G2)
6. Projektordner waehlen

**Via Kommandozeile (Projekt von Template klonen):**
```bash
cd ~/projects
git clone https://github.com/aurpelai/garmin-watchface-template.git windfall
cd windfall
rm -rf .git
git init
```

---

## Schritt 8: Device-Dateien herunterladen

Fuer den Simulator benoetigt man die Device-Dateien des Zielgeraets:

**Via SDK Manager GUI:**
1. SDK Manager starten
2. Tab "Devices" oeffnen
3. "Descent G2" suchen und herunterladen

**Via CLI:**
```bash
# Alle Geraete aus manifest.xml herunterladen
connect-iq-sdk-manager device download --manifest=manifest.xml

# Oder einzeln (wenn bekannt)
connect-iq-sdk-manager device download descentg2
```

---

## Schritt 9: Build und Test

### In VS Code

1. `.mc`-Datei oeffnen
2. Target Device setzen: Command Palette > "Monkey C: Edit Products" > Descent G2 auswaehlen
3. Build und Simulator starten: `F5` oder "Run > Run Without Debugging"

### Via Kommandozeile

```bash
# Fuer Simulator kompilieren
monkeyc \
  -d descentg2 \
  -f monkey.jungle \
  -o bin/Windfall.prg \
  -y ~/.garmin/developer_key.der

# Simulator starten
connectiq &

# App im Simulator ausfuehren
monkeydo bin/Windfall.prg descentg2

# Fuer Release/Veroeffentlichung kompilieren
monkeyc \
  -e \
  -w \
  -f monkey.jungle \
  -o bin/Windfall.iq \
  -y ~/.garmin/developer_key.der
```

### Auf dem Geraet installieren

```bash
# Geraet per USB verbinden
# .prg-Datei in den GARMIN/APPS-Ordner kopieren
cp bin/Windfall.prg /media/$USER/GARMIN/GARMIN/APPS/
```

---

## Schritt 10: Projekt-Konfiguration fuer Descent G2

### manifest.xml

```xml
<?xml version="1.0"?>
<iq:manifest xmlns:iq="http://www.garmin.com/xml/connectiq"
             version="3">
    <iq:application
        entry="WindfallApp"
        id="your-uuid-here"
        launcherIcon="@Drawables.LauncherIcon"
        minApiLevel="5.1.0"
        name="@Strings.AppName"
        type="watchface">
        <iq:products>
            <iq:product id="descentg2"/>
        </iq:products>
        <iq:permissions>
            <iq:uses-permission id="Sensor"/>
            <iq:uses-permission id="SensorHistory"/>
        </iq:permissions>
        <iq:languages>
            <iq:language>deu</iq:language>
            <iq:language>eng</iq:language>
        </iq:languages>
    </iq:application>
</iq:manifest>
```

---

## Bekannte Probleme auf Linux

### Problem 1: SDK Manager startet nicht (webkit2gtk-4.0)
**Symptom:** `error while loading shared libraries: libwebkit2gtk-4.0.so`
**Loesung:** AppImage verwenden (Option B) oder CLI Manager (Option A)

### Problem 2: Simulator zeigt schwarzen Bildschirm
**Symptom:** Simulator startet, aber kein Display
**Loesung:** Sicherstellen, dass die richtige Java-Version verwendet wird und `DISPLAY` gesetzt ist

### Problem 3: VS Code Extension findet SDK nicht
**Symptom:** "Connect IQ SDK not found"
**Loesung:**
```
# In VS Code Settings (JSON):
{
    "monkeyC.connectIQ.sdkPath": "/pfad/zum/sdk"
}
```

### Problem 4: Permission Denied bei SDK-Tools
**Symptom:** `Permission denied: monkeyc`
**Loesung:**
```bash
chmod +x $SDKROOT/bin/*
```

### Problem 5: Garmin Login im SDK Manager schlaegt fehl
**Symptom:** Login-Bildschirm erscheint nicht oder ist leer
**Loesung:** CLI-Tool verwenden mit Umgebungsvariablen:
```bash
export GARMIN_USERNAME="dein.benutzername@email.com"
export GARMIN_PASSWORD="dein-passwort"
connect-iq-sdk-manager sdk set 7.3.1
```

---

## Nuetzliche VS Code Shortcuts

| Shortcut | Aktion |
|---|---|
| `Ctrl+Shift+P` | Command Palette |
| `F5` | Build + Simulator starten |
| `Ctrl+Shift+B` | Build Task ausfuehren |
| "Monkey C: Edit Products" | Zielgeraet aendern |
| "Monkey C: Build for Device" | Release-Build erstellen |

---

## Quellen

- [Garmin Connect IQ Getting Started](https://developer.garmin.com/connect-iq/connect-iq-basics/getting-started/)
- [Garmin SDK Download](https://developer.garmin.com/connect-iq/sdk/)
- [Monkey C VS Code Extension](https://marketplace.visualstudio.com/items?itemName=garmin.monkey-c)
- [VS Code Extension Referenz](https://developer.garmin.com/connect-iq/reference-guides/visual-studio-code-extension/)
- [Command Line Setup](https://developer.garmin.com/connect-iq/reference-guides/monkey-c-command-line-setup/)
- [SDK Manager AppImage (Linux)](https://github.com/pcolby/connectiq-sdk-manager)
- [SDK Manager CLI](https://github.com/lindell/connect-iq-sdk-manager-cli)
- [Docker-Umgebung](https://github.com/waterkip/connectiq-sdk-docker)
- [Ubuntu 22.04 Setup Guide](https://jamesephelps.com/2023/02/07/installing-garmin-sdk-in-ubuntu-22-04/)
- [Ubuntu 20 Setup Guide](https://monzool.net/blog/2021/10/22/installing-garmin-connect-iq-sdk-on-ubuntu-20/)
- [Garmin Forum: SDK under Linux](https://forums.garmin.com/developer/connect-iq/f/discussion/196895/garmin-sdk-under-linux)
- [Getting Started Tutorial (Ottorino Bruni)](https://www.ottorinobruni.com/getting-started-with-garmin-connect-iq-development-build-your-first-watch-face-with-monkey-c-and-vs-code/)
