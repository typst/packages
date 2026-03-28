# HWR Berlin — Typst-Template

Automatische Formatierung für Praxistransferberichte, Haus-/Studien- und Bachelorarbeiten an der HWR Berlin.
Konform mit den HWR-Richtlinien **Stand Januar 2025** — für alle Kohorten.

Du konzentrierst dich auf den Inhalt. Das Template erledigt den Rest:
- Deckblatt mit allen Pflichtangaben
- Inhaltsverzeichnis, Abkürzungsverzeichnis, Abbildungs-/Tabellenverzeichnis
- Seitennummerierung (Römisch → Arabisch, automatischer Wechsel)
- Ehrenwörtliche Erklärung mit 2025 KI-Klausel
- KI-Verzeichnis (wenn KI-Tools genutzt wurden)

---

## Was ist Typst?

Typst ist ein Schreibwerkzeug — ähnlich wie Word, aber du schreibst in reinen Textdateien (`.typ`) statt in einem grafischen Editor. Das Template übernimmt dann automatisch alle Formatierungen. Die fertigen Dateien kompilierst du per Klick oder Befehl zu einer PDF-Datei.

**Vorteil:** Keine manuelle Formatierungsarbeit, kein Verschieben von Seitenumbrüchen, keine Style-Kämpfe.

---

## Schritt 1: Typst installieren

### macOS

1. Öffne das Terminal (Programme → Dienstprogramme → Terminal)
2. Tippe:
   ```
   brew install typst
   ```
   Falls `brew` nicht vorhanden ist: [https://brew.sh](https://brew.sh) — dort den Installationsbefehl kopieren und ausführen, danach nochmals `brew install typst`

### Windows

1. Öffne PowerShell (Startmenü → „PowerShell" suchen)
2. Tippe:
   ```
   winget install --id Typst.Typst
   ```
   Alternativ: Auf [typst.app/download](https://typst.app/download) die Windows-Installationsdatei herunterladen.

### Linux

```bash
# Ubuntu/Debian:
sudo snap install typst

# Arch:
sudo pacman -S typst

# Oder direkt über cargo:
cargo install typst-cli
```

### Prüfen ob Typst funktioniert

Nach der Installation im Terminal eingeben:
```
typst --version
```
→ Es sollte eine Versionsnummer erscheinen (z.B. `typst 0.13.1`).

---

## Schritt 2: Schriftart installieren

Das Template verwendet **Times New Roman** (HWR-Vorschrift).

- **Windows/macOS:** Bereits vorinstalliert — kein Handlungsbedarf.
- **Linux:** Im Terminal:
  ```bash
  sudo apt install ttf-mscorefonts-installer   # Ubuntu/Debian
  # oder:
  sudo apt install fonts-liberation
  ```

---

## Schritt 3: Projekt einrichten — zwei Wege

### Weg A — Typst Universe (ein Befehl)

```bash
typst init @preview/wi-hwr-berlin:0.1.0 meine-arbeit
cd meine-arbeit
typst watch main.typ   # Live-Vorschau, Beenden: Ctrl+C
```

Das erstellt sofort einen fertigen Projektordner mit einer vorausgefüllten `main.typ`.

### Weg B — interaktives Setup-Script (empfohlen für Einsteiger)

Das Script stellt dir alle Fragen und erstellt eine vollständig ausgefüllte `main.typ` mit deinen Daten.

**Methode 1 — direkt aus dem Web (macOS/Linux, kein Download nötig):**

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/lultoni/hwr-typst-template/main/scripts/init.sh)
```

**Methode 2 — nach ZIP-Download:**

Auf der GitHub-Seite: **Code → Download ZIP** → entpacken, dann:
```bash
# Terminal in den entpackten Ordner öffnen, dann:
bash scripts/init.sh
```

Das Script fragt dich der Reihe nach:
- Wo soll das Projekt erstellt werden?
- Name des Projektordners
- Art der Arbeit (PTB, Hausarbeit, Bachelorarbeit, …)
- Dein Name und Matrikelnummer
- Titel, Prüfer/in, Betrieb, Fachrichtung, Jahrgang
- Gewünschte Anzahl Kapitel

Am Ende hast du einen fertigen Projektordner mit vorausgefüllter `main.typ`.

> **Sicherheitshinweis (Methode 1):** Bevor du ein Script aus dem Internet ausführst, kannst du es dir vorher ansehen: [scripts/init.sh](https://github.com/lultoni/hwr-typst-template/blob/b896349435398df149f88e27f6cb3fd92a3883e2/scripts/init.sh)

---

## Schritt 4: Schreiben

Öffne den Projektordner in einem Texteditor. Empfohlen: **VS Code** (kostenlos, [code.visualstudio.com](https://code.visualstudio.com)) mit der **Tinymist**-Erweiterung für Syntax-Highlighting.

```
meine-arbeit/
├── main.typ            ← deine Metadaten (Titel, Name, …) — hier arbeitest du
├── refs.bib            ← deine Quellen
├── kapitel/
│   ├── 01_einleitung.typ   ← hier schreibst du
│   ├── 02_theoretische_grundlagen.typ
│   └── ...
└── anhang/
    └── beispiel.typ        ← Anhang-Vorlage
```

**Schreiben in den Kapitel-Dateien:**
```typst
= Einleitung

Hier beginnt der Text des ersten Kapitels.

== Hintergrund

*Fettschrift* und _Kursivschrift_ funktionieren so.

Fußnote#footnote[Hier steht der Fußnotentext.] direkt im Text.

Zitat aus einer Quelle: Laut @mustermann2024 gilt...

Abkürzung beim ersten Vorkommen: #abk("KI")
```

**Abkürzungen** funktionieren vollautomatisch:
- Erste Verwendung: `#abk("KI")` → gibt aus „Künstliche Intelligenz (KI)"
- Alle weiteren: `#abk("KI")` → gibt aus „KI"
- Das Abkürzungsverzeichnis wird automatisch erstellt

Die Abkürzungen trägst du einmalig in `main.typ` ein:
```typst
abbreviations: (
  "KI":  "Künstliche Intelligenz",
  "HWR": "Hochschule für Wirtschaft und Recht Berlin",
  "ERP": "Enterprise Resource Planning",
),
```

---

## Schritt 5: PDF erstellen

```bash
# Im Projektordner (z.B. cd meine-arbeit):

# Einmalig erstellen:
typst compile main.typ

# Mit Live-Vorschau (aktualisiert bei jedem Speichern):
typst watch main.typ
# Beenden: Ctrl+C
```

Die fertige PDF liegt direkt neben `main.typ`.

### VS Code + Tinymist

Tinymist liefert Syntax-Highlighting und Autocomplete für `.typ`-Dateien. Du kannst auch direkt aus VS Code heraus kompilieren — Tinymist zeigt eine Live-Vorschau im Editor-Fenster.

---

## Quellen eintragen

Quellen gehören in die Datei `refs.bib`. Format-Beispiele (Citavi, Zotero oder Google Scholar können diese Dateien automatisch exportieren):

```bibtex
@book{mustermann2024,
  author    = {Mustermann, Max},
  title     = {Titel des Buches},
  year      = {2024},
  publisher = {Verlag},
}

@online{quelle2024,
  author  = {Autor, Vorname},
  title   = {Titel der Webseite},
  year    = {2024},
  url     = {https://beispiel.de},
  urldate = {2024-01-01},
}
```

Im Text zitierst du mit `@schlüssel`, also z.B. `@mustermann2024`.

---

## KI-Tools eintragen (Pflicht bei KI-Nutzung)

Wenn du KI-Tools wie ChatGPT, Copilot oder DeepL verwendet hast, musst du das laut HWR §3.8 angeben.
In `main.typ`:

```typst
ai-tools: (
  (
    tool:     "ChatGPT 4o",
    usage:    "Textvorschläge, im Text gekennzeichnet",
    chapters: "Kapitel 1, S. 3",
    bemerkungen: "Prompts: siehe Anhang 1",  // optional
  ),
  (
    tool:     "DeepL Translator",
    usage:    "Übersetzung englischer Quellabschnitte",
    chapters: "Gesamte Arbeit",
  ),
),
```

Das KI-Verzeichnis wird automatisch als letztes Anhang-Item eingefügt. Bei `ai-tools: ()` erscheint kein Verzeichnis.

---

## Gruppenarbeit

Einfach weitere Autoren eintragen:

```typst
authors: (
  (name: "Max Mustermann", matrikel: "12345678"),
  (name: "Lisa Müller",    matrikel: "87654321"),
),
```

Die Ehrenwörtliche Erklärung wechselt automatisch auf „Wir erklären…" und beide Autoren erhalten ein Unterschriftsfeld.

**Nur eine stellvertretende Unterschrift** (z.B. bei digitaler Abgabe im Namen der Gruppe — bitte mit dem Prüfer abklären):

```typst
group-signature: false,  // nur erster Autor unterschreibt
```

Das Template zeigt dann einen gelben Hinweis im PDF, der daran erinnert, dies mit dem Prüfer abzusprechen.

---

## Digitale Unterschrift einbinden (optional)

Statt einer leeren Linie zum handschriftlichen Unterschreiben kannst du ein Bild deiner Unterschrift einbinden:

1. Unterschrift auf weißem Papier, einscannen oder abfotografieren
2. Als PNG oder SVG unter `images/` im Projektordner speichern
3. In `main.typ` beim Autoren-Eintrag ergänzen:

```typst
authors: (
  (name: "Max Mustermann", matrikel: "12345678", signature: "images/signatur_max.png"),
),
```

Das Bild erscheint dann automatisch im Unterschriftsfeld der Ehrenwörtlichen Erklärung.

---

## Sperrvermerk

Falls Teile der Arbeit vertraulich sind (§3.2.1):

```typst
// Gesamte Arbeit gesperrt:
confidential: true,

// Nur bestimmte Kapitel:
confidential: (
  chapters: (
    (number: "3", title: "Methodik"),
    (number: "4", title: "Ergebnisse"),
  ),
  filename: "PTB_Mustermann_oeffentlich.pdf",  // optional
),
```

Der Pflichttext wird automatisch eingefügt und erscheint vor dem Deckblatt.

---

## Englische Arbeiten

```typst
lang: "en",
citation-style: "harvard-anglia-ruskin-university",
```

Alle Verzeichnisüberschriften, die Ehrenwörtliche Erklärung und das KI-Verzeichnis wechseln automatisch auf Englisch. Der Harvard-Stil entspricht den HWR-Anforderungen für englischsprachige Arbeiten (§6).

---

## Gut zu wissen

**Zitierstil-Wahl:** Standard ist APA (für deutschsprachige Arbeiten). Wenn dein Betreuer einen anderen Stil vorgibt, kannst du eine eigene `.csl`-Datei aus dem [Zotero Style Repository](https://www.zotero.org/styles) herunterladen und direkt referenzieren:
```typst
citation-style: "./mein-stil.csl",
```

**Abkürzungsverzeichnis erscheint automatisch**, aber nur wenn:
- Abkürzungen in `abbreviations:` eingetragen sind, UND
- `#abk("XY")` mindestens einmal im Text verwendet wird

Nicht verwendete Abkürzungen tauchen im Verzeichnis nicht auf.

**Abbildungs- und Tabellenverzeichnis** erscheinen erst ab 5 Einträgen (HWR-Anforderung). Das Template prüft das automatisch.

**Abgabe als Word + PDF:** Die HWR verlangt beide Formate. Das Template erzeugt nur PDF. Die Word-Version musst du separat erstellen (z.B. via Pandoc oder Copy-Paste).

---

## Alle Parameter im Überblick

### Pflichtfelder

| Parameter | Beschreibung |
|---|---|
| `doc-type` | Art der Arbeit: `"ptb-1"`, `"ptb-2"`, `"ptb-3"`, `"hausarbeit"`, `"studienarbeit"`, `"bachelorarbeit"` |
| `title` | Titel der Arbeit |
| `authors` | Array: `((name: "...", matrikel: "..."),)` |

### Je nach Dokumenttyp Pflicht

| Parameter | Pflicht für | Beschreibung |
|---|---|---|
| `supervisor` | Alle außer Bachelorarbeit | Betreuende/r Prüfer/in mit Titel |
| `company` | Alle außer Bachelorarbeit | Name des Ausbildungsbetriebs |
| `first-examiner` | Bachelorarbeit | Erstgutachter/in mit Titel |
| `second-examiner` | Bachelorarbeit | Zweitgutachter/in mit Titel |

### Optionale Felder

| Parameter | Standard | Beschreibung |
|---|---|---|
| `lang` | `"de"` | Dokumentsprache — `"de"` oder `"en"` |
| `field-of-study` | `"Wirtschaftsinformatik"` | Fachrichtung |
| `cohort` | — | Studienjahrgang, z.B. `"2024"` |
| `semester` | — | Studienhalbjahr, z.B. `"3"` |
| `date` | `auto` | Abgabedatum; `auto` = heutiges Datum, oder manuell: `"15. März 2026"` |
| `abstract` | `none` | Zusammenfassung vor dem Inhaltsverzeichnis |
| `confidential` | `none` | Sperrvermerk — `none`, `true` oder `(chapters: (...), filename: ...)` |
| `abbreviations` | `(:)` | Abkürzungen als Dictionary |
| `glossary` | `()` | Glossareinträge für erklärungsbedürftige Fachbegriffe (ohne eigene Abkürzung) |
| `ai-tools` | `()` | KI-Verzeichnis-Einträge — `(tool, usage, chapters, bemerkungen?)` |
| `chapters` | `()` | Kapitel-Dateien via `include()` in gewünschter Reihenfolge |
| `appendix` | `()` | Anhang-Einträge: `(title: "...", content: include(...))` |
| `show-appendix-toc` | `false` | `true` = optionales Anhangsverzeichnis vor den Anhang-Einträgen (HWR §3.10) |
| `bibliography` | — | `bibliography("refs.bib", title: "Literaturverzeichnis")` |
| `citation-style` | `"apa"` | Zitierstil: `"apa"` (DE), `"harvard-anglia-ruskin-university"` (EN), oder Pfad zu `.csl`-Datei |
| `heading-depth` | `4` | TOC-Tiefe 1–4 (max. 4 laut HWR) |
| `declaration-lang` | `auto` | Sprache der Ehrenwörtlichen Erklärung — `auto` folgt `lang`, `"de"` immer Deutsch |
| `city` | `"Berlin"` | Ort im Unterschriftsfeld der Ehrenwörtlichen Erklärung |
| `group-signature` | `auto` | `auto`/`true` = alle Autoren unterschreiben; `false` = nur erster Autor |

### Felder im `authors`-Array

| Feld | Pflicht | Beschreibung |
|---|---|---|
| `name` | Ja | Vollständiger Name |
| `matrikel` | Ja | Matrikelnummer |
| `signature` | Nein | Pfad zur Unterschriften-Bilddatei (PNG/SVG), z.B. `"images/signatur.png"` |

---

## Häufige Probleme

| Problem | Lösung |
|---|---|
| `doc-type "..." ist ungültig` | Wert muss exakt `"ptb-1"`, `"ptb-2"`, `"ptb-3"`, `"hausarbeit"`, `"studienarbeit"` oder `"bachelorarbeit"` sein |
| `supervisor ist Pflicht für...` | Für alle Typen außer `"bachelorarbeit"` müssen `supervisor:` und `company:` gesetzt sein |
| Times New Roman fehlt (Linux) | `sudo apt install ttf-mscorefonts-installer` |
| Abkürzung erscheint nicht im Verzeichnis | `#abk("XY")` muss im Text vorkommen — nur verwendete Abkürzungen erscheinen |
| KI-Verzeichnis fehlt | `ai-tools:` braucht mindestens einen Eintrag; bei `ai-tools: ()` erscheint kein Verzeichnis |
| Abbildungsverzeichnis fehlt | Erscheint erst ab 5 Abbildungen (HWR-Anforderung) |
| Kapitel erscheint nicht im PDF | Prüfe ob die Datei in der `chapters:`-Liste in `main.typ` eingetragen ist |
| Import-Fehler bei `include()` | Pfade in `chapters:` sind relativ zu `main.typ` — `include("kapitel/01_einleitung.typ")` |

---

## Lizenz

MIT — siehe LICENSE
