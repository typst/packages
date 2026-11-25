# Wissenschaftliche Arbeit – Schnellstart

**Sprache:** [English](README.md) | **Deutsch**

Dieses Projekt verwendet **Academic Template**, eine [Typst](https://typst.app/)-Vorlage, die für die Formatierungs- und Zitiervorgaben der **IU Internationalen Hochschule** vorkonfiguriert ist. Über `config.typ` kannst du die Einstellungen an andere Anforderungen anpassen.

> **Inoffizielles Projekt.** Dieses Template wurde unabhängig entwickelt und wird weder von der IU Internationalen Hochschule herausgegeben noch von ihr unterstützt oder gepflegt. Prüfe vor der Abgabe die aktuellen Vorgaben für deinen Kurs und deine Prüfungsleistung.

## Erste Schritte

1. Trage die Angaben zu deiner Arbeit in `config.typ` ein und passe dort die Formatierung an.
2. Ersetze die Beispielkapitel und -texte in `content.typ` durch deine eigenen Inhalte.
3. Ergänze oder aktualisiere deine Quellen in `references.json` oder wähle in `config.typ` eine alternative Literaturdatei aus.
4. Definiere bei Bedarf Abkürzungen in `abbreviations.typ` und füge Anhänge in `appendices.typ` hinzu.
5. Speichere Bilder, Diagramme und andere in deiner Arbeit verwendete Dateien im Ordner `assets/` (lege ihn bei Bedarf an).

**Kompiliere immer `main.typ`** und nicht die anderen `.typ`-Dateien, da `main.typ` das vollständige Dokument zusammenstellt. Führe dazu im Projektordner folgenden Befehl aus:

```bash
typst compile main.typ
```

Dadurch wird `main.pdf` erstellt. Um die PDF bei Änderungen an den Quelldateien automatisch neu zu erzeugen, verwende `typst watch main.typ`.

Für die lokale PDF-Erstellung benötigst du **Typst CLI ab Version 0.15.0** und Zugriff auf das in `project.typ` angegebene Template-Paket. In der **Typst-Web-App** aktualisiert sich die Vorschau während der Bearbeitung automatisch. Dort kannst du die PDF-Datei direkt exportieren.

In **Visual Studio Code** kannst du deine Projektdateien mit der Erweiterung **Tinymist** direkt bearbeiten. Für den Export oder die Vorschau des vollständigen Dokuments öffnest du `main.typ` und stellst sicher, dass die Datei im Editor aktiv ist. Öffne die Befehlspalette mit `Ctrl+Shift+P` (Windows/Linux) beziehungsweise `Cmd+Shift+P` (macOS). Alternativ kannst du `Ctrl+P` oder `Cmd+P` drücken und `>` eingeben. Suche anschließend nach einem Typst-Befehl wie `Typst: Export the Opened File as PDF` oder `Typst Preview: Preview Opened File in Browser` (die verfügbaren Befehle hängen von der installierten Erweiterung ab).

## Projektdateien

| Datei oder Ordner | Zweck |
| --- | --- |
| `config.typ` | Angaben zur Arbeit, Sprache, Formatierung, Verzeichnisse und Literatureinstellungen |
| `content.typ` | Hauptkapitel und Fließtext |
| `references.json` | Standard-Literaturdatei im CSL-JSON-Format |
| `references.bib`, `references.yaml` | Optionale alternative Literaturdateien |
| `abbreviations.typ` | Definitionen von Abkürzungen |
| `appendices.typ` | Optionale Anhänge und ergänzende Materialien |
| `assets/` | Bilder, Diagramme, Logos und andere in der Arbeit verwendete Dateien; bei Bedarf selbst anlegen |
| `main.typ` | Einstiegspunkt zum Kompilieren des vollständigen Dokuments; normalerweise keine Änderungen erforderlich |
| `project.typ` | Verbindung zum Template-Paket; normalerweise keine Änderungen erforderlich |

Die Implementierung des Templates befindet sich **nicht in diesem Projekt**. Paketname und Version sind in `project.typ` festgelegt. Diese Datei importiert das Template aus `@preview` (Typst Universe) oder `@local` (lokale Installation).

## Sprache und Formatierung

Stelle in `config.typ` `language: "de"` für Deutsch oder `language: "en"` für US-Englisch ein. Dadurch ändern sich automatisch erzeugte Bezeichnungen und sprachabhängige Formatierungen; dein Text wird dadurch **nicht übersetzt**.

Bei den Schriftarten wird standardmäßig **Arial** bevorzugt. Falls Arial nicht verfügbar ist (beispielsweise in der Web-App), wird **Liberation Sans** verwendet. Diese Einstellung kannst du in `config.typ` ändern. Prüfe die fertige PDF anhand der Formatierungsvorgaben deiner Hochschule, da Ersatzschriftarten das Layout beeinflussen können.

## Literatur und Zitate

Standardmäßig verwendet das Template die empfohlene Kombination **Citrus + CSL-JSON (`references.json`) + IU-Zitierstil**. Für den APA-Zitierstil kannst du in `config.typ` `style: "apa"` auswählen. Andere Zitier-Engines und Literaturformate werden ebenfalls unterstützt. Prüfe bei diesen Alternativen die Quelldaten und die erzeugten Zitate sorgfältig.

Die mitgelieferten Literaturdateien enthalten Beispiele, werden aber **nicht automatisch miteinander synchronisiert**. Bearbeite deshalb die Datei, die in `config.typ` ausgewählt ist. Weitere Informationen zur Literaturverwaltung, zu Zitiermethoden und zum Literaturverzeichnis findest du im Bibliography Guide.

## Dokumentation und Beispiele

- Informationen zur Installation und zu Updates findest du in der README des Hauptrepositories ([English](https://github.com/BeaverBytes/academic-template/blob/main/README.md) | [Deutsch](https://github.com/BeaverBytes/academic-template/blob/main/README.de.md)).
- Eine ausführliche Anleitung zur Verwendung des Templates bietet der User Guide ([English](https://github.com/BeaverBytes/academic-template/blob/v1.0.0/docs/user-guide.pdf) | [Deutsch](https://github.com/BeaverBytes/academic-template/blob/v1.0.0/docs/user-guide.de.pdf)).
- Informationen zu Literaturformaten, Zitiermethoden und Literaturverzeichnissen findest du im Bibliography Guide ([English](https://github.com/BeaverBytes/academic-template/blob/v1.0.0/docs/bibliography-guide.pdf) | [Deutsch](https://github.com/BeaverBytes/academic-template/blob/v1.0.0/docs/bibliography-guide.de.pdf)).

- Im [Demo-Projekt](https://github.com/BeaverBytes/academic-template/tree/v1.0.0/demo) kannst du die Funktionen des Templates kennenlernen und sehen, wie ein fertig formatiertes Dokument aussehen kann.

**Vor der Abgabe:** Ersetze die Beispieltexte und Literaturangaben, überprüfe die Angaben zu deiner Arbeit und gleiche Formatierung und Zitate mit den aktuellen kurs- und prüfungsspezifischen Vorgaben ab. Das Template garantiert nicht die Einhaltung aller Anforderungen.

## Lizenz

Die Dateien dieser Projektvorlage stehen unter [MIT No Attribution (MIT-0)](LICENSE). Für die separat installierte Template-Bibliothek und ihre eingebundenen Drittanbieterkomponenten gelten eigene Lizenzen. Allein durch die Verwendung des Templates entsteht keine Pflicht, BeaverBytes in der wissenschaftlichen Arbeit zu nennen.
