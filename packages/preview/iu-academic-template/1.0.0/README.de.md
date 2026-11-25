# Academic Template

Eine modulare [Typst](https://typst.app/)-Vorlage für wissenschaftliche Arbeiten, die für die Formatierungs- und Zitiervorgaben der **IU Internationalen Hochschule vorkonfiguriert** ist. Über die `config.typ` jeder Arbeit lassen sich die Standardeinstellungen anpassen, sodass das Template auch für andere Anforderungen verwendet werden kann. Mit Typst werden aus einfachen Quelldateien professionell gesetzte PDF-Dokumente.

**Sprache:** [English](README.md) | **Deutsch**

> **Inoffizielles Projekt.** Academic Template wurde unabhängig entwickelt und wird weder von der IU Internationalen Hochschule herausgegeben noch von ihr unterstützt oder gepflegt. Prüfe vor jeder Abgabe die aktuellen Vorgaben deines Kurses und deiner Prüfungsleistung.

**Paketversion:** `1.0.0`
**Bezug:** Typst Universe (`@preview`); alternativ ist eine lokale Installation aus dem Quellcode möglich.

## Was bietet das Template?

- Konfigurierbares Deckblatt, Seitenlayout, Überschriften und Seitennummerierung
- Deutsche (`de`) und US-englische (`en`) Beschriftungen und Dokumenteinstellungen
- Automatische Inhalts-, Abbildungs-, Tabellen- und Abkürzungsverzeichnisse
- Abbildungen und Tabellen mit einheitlichen Beschriftungen, Anmerkungen und Quellenhinweisen
- Anhänge mit konfigurierbarer Nummerierung für Abbildungen und Tabellen
- Zitate und Literaturverzeichnis mit IU-orientiertem Stil und APA
- Unabhängige Arbeiten, die denselben installierten Template-Kern verwenden

**Empfohlene Literaturkonfiguration:** **Citrus + CSL-JSON + IU-Stil**. Andere Engine-/Dateikombinationen sind möglich; dort müssen Metadaten und Zitierausgabe eigenständig geprüft werden. Näheres steht in den [Literaturleitfäden](#dokumentation).

## Voraussetzungen

- **Für die lokale Arbeit:** Typst-CLI ab Version 0.15.0 und ein Texteditor deiner Wahl (beispielsweise Visual Studio Code mit Tinymist)
- **Für die Online-Arbeit:** Ein Browser und ein Konto für die Typst-Web-App; eine lokale Installation ist nicht erforderlich

Als Standardschrift wird **Arial** bevorzugt; falls Arial nicht verfügbar ist (beispielsweise in der Web-App), wird **Liberation Sans** verwendet. In `config.typ` kannst du auch eine andere Schrift angeben. Eine Ersatzschrift kann den Umbruch verändern – prüfe deshalb das fertige PDF anhand der Vorgaben deiner Hochschule.

### Typst installieren

Installiere den Typst-Compiler für die Kommandozeile, **bevor** du eine Arbeit initialisierst. Das ist ein separater Schritt zur Installation des Academic Templates.

**Windows** (PowerShell):

```powershell
winget install --id Typst.Typst
```

**macOS** (Homebrew):

```bash
brew install typst
```

**Linux:** Installiere das Paket `typst` über die Paketverwaltung deiner Distribution oder lade die passende ausführbare Datei von der [offiziellen Typst-Installationsseite](https://typst.app/open-source/) herunter.

Prüfe die Installation in einem neuen Terminal:

```bash
typst --version
```

Weitere Installationsmöglichkeiten findest du in der [offiziellen Typst-Installationsanleitung](https://typst.app/open-source/).

## Schnellstart über Typst Universe (empfohlen)

**In der Typst-Web-App (ohne Installation):** Öffne die [Typst-Web-App](https://typst.app/), melde dich an, wähle **Start from template**, suche nach **iu-academic-template** und erstelle ein neues Projekt. Bearbeite deine Arbeit im Browser, nutze die Live-Vorschau und exportiere das fertige PDF.

**Mit der lokalen Typst-CLI:** Sobald Typst installiert ist, erstelle eine neue wissenschaftliche Arbeit mit dem veröffentlichten Template:

```bash
typst init @preview/iu-academic-template:1.0.0 my-paper
cd my-paper
```

Typst lädt das veröffentlichte Paket automatisch herunter. Öffne den neuen Projektordner in deinem Editor. Unabhängig davon, ob du die Web-App oder die lokale CLI verwendest, kannst du wie folgt vorgehen:

1. Trage deine Angaben ein und passe die Formatierung in `config.typ` an.
2. Verfasse deine Kapitel und den Haupttext in `content.typ`.
3. Ergänze oder aktualisiere Quellen in `references.json` (alternativ `references.bib` oder `references.yaml` mit entsprechender Konfiguration).
4. Definiere bei Bedarf Abkürzungen in `abbreviations.typ` und verwende sie im Text.
5. Ergänze bei Bedarf Anhänge in `appendices.typ` und speichere Bilder, Diagramme oder andere in deiner Arbeit verwendete Dateien im Ordner `assets/`.

**Bei lokalen Projekten** erstellst du die PDF-Datei im Projektordner mit:

```bash
typst compile main.typ
```

Dadurch wird `main.pdf` erstellt. Kompiliere immer `main.typ` und nicht die anderen `.typ`-Dateien, da `main.typ` der Einstiegspunkt ist, der das gesamte Dokument zusammenstellt. Um die PDF-Datei bei Änderungen an den Quelldateien automatisch neu zu erstellen, verwende stattdessen `typst watch main.typ`. **In der Web-App** wird die Vorschau während der Bearbeitung aktualisiert; die PDF-Datei kannst du direkt exportieren.

**Mit Visual Studio Code:** Öffne den Projektordner über **File → Open Folder** und installiere die Erweiterung **Tinymist**. Anschließend kannst du die `.typ`-Dateien deines Projekts direkt in VS Code bearbeiten, darunter `config.typ`, `content.typ`, `abbreviations.typ` und `appendices.typ`.

Um das vollständige Dokument als PDF zu exportieren, öffne `main.typ` und stelle sicher, dass diese Datei im Editor aktiv ist. Öffne anschließend die Befehlspalette mit `Ctrl+Shift+P` (Windows/Linux) oder `Cmd+Shift+P` (macOS); alternativ kannst du `Ctrl+P` beziehungsweise `Cmd+P` drücken und `>` eingeben. Suche nach Typst-Befehlen wie `Typst: Export the Opened File as PDF` oder `Typst: Preview opened File in Browser` (die verfügbaren Befehle hängen von der installierten Erweiterung ab).

Alternativ kannst du im integrierten Terminal (**Terminal → New Terminal**) `typst compile main.typ` oder `typst watch main.typ` ausführen und die erzeugte PDF-Datei in einem PDF-Viewer öffnen.

**Mit Zotero (optional):** Verwalte deine Quellen in Zotero und exportiere sie als **CSL-JSON** (`references.json`, empfohlen) oder **BibLaTeX** (`references.bib`). Zotero unterstützt auch den Export als BibTeX, das sich von BibLaTeX unterscheidet; **Hayagriva-YAML** erfordert eine Konvertierung. Prüfe die exportierten Metadaten und Zitierkennungen. Weitere Informationen findest du im [Literaturleitfaden](https://github.com/BeaverBytes/academic-template/blob/v1.0.0/docs/bibliography-guide.de.pdf).

Die [Starter-README](starter/README.de.md) bietet eine Kurzanleitung für die tägliche Arbeit; ausführliche Erklärungen findest du in den Benutzerhandbüchern.

Ein vollständiges Beispiel findest du im Ordner [`demo/`](https://github.com/BeaverBytes/academic-template/tree/v1.0.0/demo/). Die dort enthaltene wissenschaftliche Musterarbeit demonstriert die Funktionen des Templates und zeigt, wie ein fertig formatiertes Dokument aussehen kann. Weitere Informationen findest du in der [Demo-README](https://github.com/BeaverBytes/academic-template/blob/v1.0.0/demo/README.de.md).

## Lokale Installation aus dem Quellcode (optional)

Für die Entwicklung des Templates oder eine lokale Installation benötigst du zunächst das Quellrepository:

- **Mit Git klonen:** Klone das Quellrepository von GitHub:

  ```bash
  git clone https://github.com/BeaverBytes/academic-template.git
  cd academic-template
  ```

- **Als ZIP herunterladen:** Wähle auf GitHub **Code → Download ZIP**, entpacke das Archiv und öffne im Terminal den entpackten Ordner, der die Datei `typst.toml` enthält.

Führe den Installer anschließend **aus diesem Ordner** aus:

**Linux / macOS** (Bash):

```bash
chmod +x install.sh
./install.sh
```

**Windows** (PowerShell 5.1 oder 7):

```powershell
.\install.ps1
```

Falls PowerShell die Ausführung des Skripts blockiert, prüfe es zuerst. Bei einem vertrauenswürdigen Skript kannst du die Ausführung ausschließlich für die aktuelle Sitzung erlauben:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\install.ps1
```

**Nach Abschluss der lokalen Installation** initialisierst du eine neue Arbeit (in dem Verzeichnis, in dem sie erstellt werden soll):

```bash
typst init @local/iu-academic-template:1.0.0 my-paper-local
cd my-paper-local
typst compile main.typ
```

Der Installer bereitet den `@local`-Import in der **lokal installierten Starter-Kopie** vor. Er verändert weder die Starter-Dateien im Repository noch die `project.typ`-Dateien bereits bestehender Arbeiten. Bei neu initialisierten lokalen Projekten ist keine manuelle Anpassung des Imports erforderlich. Administratorrechte sind normalerweise nicht nötig. Zum Bearbeiten und Kompilieren gelten dieselben Schritte wie im [Schnellstart](#schnellstart-über-typst-universe-empfohlen).

## Projektaufbau

Jede neue Arbeit erhält eigene Einstellungen, Texte, Literaturdaten, Abkürzungen und gegebenenfalls Anhänge. Die Datei `project.typ` verbindet die Arbeit mit der gemeinsam installierten Template-Bibliothek. `main.typ` und `project.typ` musst du normalerweise nicht bearbeiten.

| Datei im neuen Projekt | Zweck |
| --- | --- |
| `config.typ` | Deckblatt, Sprache, Formatierung, Verzeichnisse und Literaturkonfiguration |
| `content.typ` | Hauptkapitel und Text |
| `references.json` | Standard-Literaturdatei im CSL-JSON-Format |
| `references.bib`, `references.yaml` | Optionale alternative Literaturdateien |
| `abbreviations.typ`, `appendices.typ` | Optionale Abkürzungen und Anhänge |
| `main.typ`, `project.typ` | Dokumentzusammenstellung und Verbindung zum installierten Paket |

Das öffentliche Quellrepository besteht im Wesentlichen aus folgenden Komponenten:

```text
academic-template/
├── typst.toml       # Paketkonfiguration
├── template/        # Gemeinsamer Template-Kern
├── vendor/          # Eingebundene Citrus-Abhängigkeit
├── starter/         # Dateien für typst init
├── demo/            # Kompakte Beispielarbeit
├── docs/            # Benutzerhandbücher und Literaturleitfäden
├── install.sh       # Installer für Linux/macOS
└── install.ps1      # Installer für Windows
```

## Dokumentation

| Dokument | Zweck |
| --- | --- |
| [Starter-README (Deutsch)](starter/README.de.md) / [English](starter/README.md) | Kurzanleitung für die tägliche Arbeit in einem neuen Projekt |
| [Benutzerhandbuch (Deutsch)](https://github.com/BeaverBytes/academic-template/blob/v1.0.0/docs/user-guide.de.pdf) / [English](https://github.com/BeaverBytes/academic-template/blob/v1.0.0/docs/user-guide.pdf) | Ausführliche Anleitung zum Schreiben und zur Verwendung der Template-Funktionen |
| [Literaturleitfaden (Deutsch)](https://github.com/BeaverBytes/academic-template/blob/v1.0.0/docs/bibliography-guide.de.pdf) / [English](https://github.com/BeaverBytes/academic-template/blob/v1.0.0/docs/bibliography-guide.pdf) | Quellen erfassen, Literaturformate, Zitierweisen und Ausgabe des Literaturverzeichnisses |
| [Demo-README (Deutsch)](https://github.com/BeaverBytes/academic-template/blob/v1.0.0/demo/README.de.md) / [English](https://github.com/BeaverBytes/academic-template/blob/v1.0.0/demo/README.md) | Inhalt und Kompilieranleitung der Musterarbeit |

Für die allgemeine Typst-Syntax und die Verwendung der Kommandozeile siehe die [offizielle Typst-Dokumentation](https://typst.app/docs/).

## Updates

Veröffentlichte Pakete sind versioniert: Eine Arbeit verwendet weiterhin die in ihrer `project.typ` angegebene `@preview`-Version, bis du diesen Import änderst. Prüfe nach einem Versionswechsel das erzeugte PDF.

Für die lokale Entwicklung aktualisierst du zunächst das Quellrepository (z. B. mit `git pull` oder durch Herunterladen der neuesten ZIP-Datei) und führst anschließend `install.sh` oder `install.ps1` erneut aus, um die **lokal installierte Version** zu aktualisieren. Nur Projekte, die in ihrer `project.typ` dieselbe `@local`-Paketversion importieren, verwenden beim erneuten Kompilieren den aktualisierten Template-Code. Projekte mit anderen Versionen bleiben unverändert. Bestehende Projektdateien, einschließlich `project.typ`, werden **nicht** überschrieben.

**Vor der Abgabe einer Arbeit:** Prüfe ihre Formatierung und Zitation anhand der aktuell geltenden IU-Vorgaben sowie der spezifischen Anweisungen deines Kurses. Das Template dient als Hilfsmittel und garantiert keine vollständige Einhaltung aller Vorgaben.

## Lizenzen

Der eigene Projektcode und die Dokumentation stehen unter der [MIT-Lizenz](LICENSE). Davon ausgenommen sind folgende Bestandteile:

- Die Dateien in [`starter/`](starter/) stehen unter [MIT No Attribution (MIT-0)](starter/LICENSE). Diese Lizenz wird in jedes neu erzeugte Projekt mitkopiert. Für den selbst entwickelten Bibliothekscode gilt weiterhin MIT.
- Die eingebundene [Citrus-Bibliothek](vendor/citrus/) behält ihre eigene [MIT-Lizenz](vendor/citrus/LICENSE).
- Für die Zitierstile [`apa.csl`](template/styles/apa.csl) und [`iu-citrus.csl`](template/styles/iu-citrus.csl) gelten weiterhin die in den Dateien angegebenen Lizenzbedingungen **CC BY-SA 3.0**.

Wer mit dem Template eine wissenschaftliche Arbeit erstellt, muss BeaverBytes deswegen nicht in der fertigen PDF nennen. Bei der Weiterverbreitung der lizenzierten Quelldateien sind die jeweiligen Lizenzbedingungen jedoch zu beachten.
