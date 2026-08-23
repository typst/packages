# HWR Berlin — Typst-Template

**English version:** → [README-en.md](README-en.md)

Ein Community-Typst-Template für wissenschaftliche Arbeiten an der HWR Berlin (Hochschule für Wirtschaft und Recht), primär für Studierende der *Wirtschaftsinformatik*. Automatisiert Deckblatt, Verzeichnisse, Abkürzungsliste, Ehrenwörtliche Erklärung und mehr — konform mit den HWR-Richtlinien **Stand Januar 2025**, für alle Kohorten.

Du konzentrierst dich auf den Inhalt. Das Template erledigt den Rest:
- Deckblatt mit allen Pflichtangaben
- Inhaltsverzeichnis, Abkürzungsverzeichnis, Abbildungs-/Tabellenverzeichnis
- Seitennummerierung (Römisch → Arabisch, automatischer Wechsel)
- Ehrenwörtliche Erklärung mit 2025 KI-Klausel
- KI-Verzeichnis (wenn KI-Tools genutzt wurden)

> **Schnellstart:** `brew install typst && typst init @preview/easy-wi-hwr:0.1.2 meine-arbeit && cd meine-arbeit && typst watch main.typ`

> **Während des Schreibens:** [Hilfsfunktionen](#hilfsfunktionen-im-text-verwendbar)

> **Etwas funktioniert nicht?** → [Häufige Probleme](#häufige-probleme)

*Generell kann ich [Referenzen](#referenz) empfehlen sich durchzulesen.*

### Inhalt

**Erste Schritte**
- [Was ist Typst?](#was-ist-typst)
- [Schritt 1: Typst installieren](#schritt-1-typst-installieren)
- [Schritt 2: Schriftart installieren](#schritt-2-schriftart-installieren)
- [Schritt 3: Projekt einrichten](#schritt-3-projekt-einrichten--zwei-wege)
- [Schritt 4: Schreiben](#schritt-4-schreiben)
- [Schritt 5: PDF erstellen](#schritt-5-pdf-erstellen)

**Inhalte & Pflichtangaben**
- [Quellen eintragen](#quellen-eintragen)
- [KI-Tools eintragen](#ki-tools-eintragen-pflicht-bei-ki-nutzung)
- [Abkürzungen & Glossar](#abkürzungen--glossar)
- [Quellenangaben unter Abbildungen](#quellenangaben-unter-abbildungen)
- [Längere wörtliche Zitate](#längere-wörtliche-zitate)

**Optionale Features**
- [Englische Arbeiten](#englische-arbeiten)
- [Gruppenarbeit](#gruppenarbeit)
- [Sperrvermerk](#sperrvermerk)
- [Entwurfsmodus](#entwurfsmodus)
- [Digitale Unterschrift](#digitale-unterschrift-einbinden)
- [Mermaid-Diagramme](#mermaid-diagramme)
- [Pretty Mode](#pretty-mode)

**Referenz**
- [Hilfsfunktionen](#hilfsfunktionen-im-text-verwendbar)
- [Gut zu wissen](#gut-zu-wissen)
- [Alle Parameter](#alle-parameter-im-überblick)
- [Häufige Probleme](#häufige-probleme)
- [Lokale Entwicklung](#lokale-entwicklungkompilierung-für-template-entwickler)

---

# Erste Schritte

## Was ist Typst?

Typst ist ein Schreibwerkzeug — ähnlich wie Word, aber du schreibst in reinen Textdateien (`.typ`) statt in einem grafischen Editor. Du tippst z.B. `= Einleitung` und es wird automatisch eine formatierte Überschrift daraus. Das Template übernimmt dann automatisch alle Formatierungen. Die fertigen Dateien kompilierst du per Klick oder Befehl zu einer PDF-Datei.

**Vorteil:** Keine manuelle Formatierungsarbeit, kein Verschieben von Seitenumbrüchen, keine Style-Kämpfe — und das PDF ist in Millisekunden gerendert.

**Typst-Referenz und Dokumentation** → [typst.app/docs](https://typst.app/docs)

---

## Schritt 1: Typst installieren

Das Template benötigt **Typst 0.13.1 oder neuer**.

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
→ Es sollte eine Versionsnummer erscheinen (z.B. `typst 0.14.2`). Ein `(unknown hash)` dahinter kann ignoriert werden.

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

Führe folgenden Befehl im Terminal aus (in dem Verzeichnis, wo du deinen Projektordner willst):
```bash
typst init @preview/easy-wi-hwr:0.1.2 meine-arbeit
```
→ `meine-arbeit` ist der Titel des Ordners und kann angepasst werden

Das erstellt sofort einen fertigen Projektordner mit einer vorausgefüllten `main.typ`.

### Weg B — interaktives Setup-Script (optional, für Einsteiger)

Das Script stellt dir alle Fragen und erstellt eine vollständig ausgefüllte `main.typ` mit deinen Daten.

> **Hinweis:** Lies das Script kurz durch, bevor du es ausführst: [scripts/init.sh](https://github.com/lultoni/easy-wi-hwr/blob/3b53d9369c8a67afc6f45ff04b14c792b3d5356b/scripts/init.sh)

**Lokal ausführen nach Download:**
```bash
git clone https://github.com/lultoni/easy-wi-hwr.git
bash easy-wi-hwr/scripts/init.sh
```

Das Script fragt dich der Reihe nach:
- Wo soll das Projekt erstellt werden?
- Name des Projektordners
- Art der Arbeit (PTB, Hausarbeit, Bachelorarbeit, …)
- Dein Name und Matrikelnummer
- Titel, Prüfer/in, Betrieb, Fachrichtung, Jahrgang
- Sprache der Arbeit (Deutsch / Englisch)
- Gewünschte Anzahl Kapitel

Am Ende hast du einen fertigen Projektordner mit vorausgefüllter `main.typ`.

---

## Schritt 4: Schreiben

Öffne den Projektordner in einem Texteditor. Empfohlen: **VS Code** (kostenlos, [code.visualstudio.com](https://code.visualstudio.com)) mit der **Tinymist**-Erweiterung für Syntax-Highlighting, aber es kann auch in jedem anderen Texteditor gemacht werden.

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

**Alternative: Alles in einer Datei** — Du kannst auch ohne separate Kapitel-Dateien arbeiten. Lass `chapters:` leer und schreibe deinen gesamten Text direkt in `main.typ` nach dem Einstellungsblock. Zwischen Kapiteln `#pagebreak()` einfügen, damit jedes auf einer neuen Seite beginnt (bei `chapters:` passiert das automatisch):

```typst
#show: hwr.with(
  doc-type: "ptb-1",
  title: "Mein Titel",
  // ... restliche Einstellungen ...
)

= Einleitung

Hier beginnt mein Text direkt in main.typ.

#pagebreak()
= Grundlagen

Zweites Kapitel...
```

Für kürzere Arbeiten (z.B. Hausarbeiten) ist das oft einfacher. Für längere Arbeiten empfehlen sich separate Dateien in `kapitel/`.

---

## Schritt 5: PDF erstellen

```bash
# Im Projektordner (z.B. cd meine-arbeit):

# Einmalig erstellen:
typst compile main.typ

# Mit Live-Kompilierung (aktualisiert bei jedem Speichern):
typst watch main.typ
# Beenden: Ctrl+C
```

Die fertige PDF liegt direkt neben `main.typ`.

### VS Code + Tinymist

Tinymist liefert Syntax-Highlighting und Autocomplete für `.typ`-Dateien. Du kannst auch direkt aus VS Code heraus kompilieren — Tinymist zeigt eine Live-Vorschau im Editor-Fenster.

---

# Inhalte & Pflichtangaben

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
    remarks:     "Prompts: ",
    remarks-ref: "Prompt-Protokoll",   // → Hyperlink auf den Anhang mit diesem Titel
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

## Abkürzungen & Glossar

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

**Alternative: Direkt im Text definieren** — du kannst den `abbreviations:`-Block ganz weglassen und Abkürzungen beim ersten Vorkommen inline definieren:

```typst
Die #abk("KI", long: "Künstliche Intelligenz") ist wichtig.
// → Erste Nutzung: "Künstliche Intelligenz (KI)"
// → Weitere Nutzungen: #abk("KI") → "KI"
// → Verzeichnis-Eintrag wird automatisch erstellt
```

Beide Wege sind kombinierbar.

**Glossar** — für Fachbegriffe *ohne* eigene Abkürzung (z.B. „Stakeholder", „Scrum"):
```typst
glossary: (
  (key: "stakeholder", short: "Stakeholder", long: "Stakeholder",
   description: "Interessengruppen, die direkt oder indirekt von einem Projekt betroffen sind."),
),
```

Im Text: `#gls("stakeholder")` → gibt „Stakeholder" aus und verlinkt zum Glossar. Pluralform: `#glspl("stakeholder")`.

> **Hinweis:** `#gls()` expandiert beim ersten Vorkommen zu „long (short)". Bei Begriffen, wo `short` und `long` identisch sind (wie „Stakeholder"), dient der Glossar-Eintrag vor allem als Referenz-Index — die Expansion ist dann redundant. Die Abkürzungsfunktion `#abk()` ist besser geeignet für Begriffe mit echtem Kurz-/Langform-Unterschied (z.B. „KI" / „Künstliche Intelligenz").

**Regel:** Nie denselben Begriff in beide Listen — Abkürzungen ins Abkürzungsverzeichnis, Fachbegriffe ohne Abkürzung ins Glossar.

---

## Quellenangaben unter Abbildungen

Die HWR verlangt unter jeder Abbildung und Tabelle eine Quellenangabe. Das Template bietet dafür die `#quelle()`-Funktion:

```typst
// Eigene Darstellung (Standard):
#figure(
  image("images/diagramm.png"),
  caption: [Übersicht der Prozesse. #quelle()],
)
// → "Quelle: Eigene Darstellung"

// Fremde Quelle — mit klickbarem Zitier-Link (empfohlen):
#figure(
  image("images/chart.png"),
  caption: [Marktanteile 2024. #quelle(<mustermann2024>)],
)
// → "Quelle: Mustermann (2024)" (klickbarer Link ins Literaturverzeichnis)

// Mit Seitenangabe (ebenfalls klickbar):
#figure(
  table(/* Tabelleninhalt */),
  caption: [Vergleich. #quelle(<mueller2023>, "S. 42")],
)
// → "Quelle: Müller (2023), S. 42"

// Ohne Bib-Key — Freitext (wenn Quelle nicht im Literaturverzeichnis):
#figure(
  image("images/chart.png"),
  caption: [Marktanteile 2024. #quelle("Mustermann", 2024)],
)
// → "Quelle: Mustermann (2024)" (Klartext, kein Link)

// Alternative Keyword-Schreibweise (gleichwertig):
// caption: [... #quelle(author: "Mustermann", year: 2024, s: "S. 15")]
```

> **Tipp:** Verwende `#quelle(<bib-key>)` wann immer die Quelle im Literaturverzeichnis steht — dann ist der Quellenhinweis klickbar und springt direkt zum Eintrag.

> **Tabellen-Fußnoten (FMT-47):** HWR verlangt für Fußnoten *innerhalb* von Tabellen Buchstaben (a, b, c…) statt Zahlen. Typst unterstützt das nativ — verwende `#footnote(numbering: "a")` innerhalb der Tabellenzellen:
> ```typst
> table.cell[Wert#footnote(numbering: "a")[Erläuterung a]], ...
> ```

---

## Längere wörtliche Zitate

Längere Zitate (ab ca. 40 Wörtern) müssen laut HWR eingerückt und einzeilig formatiert werden (§3.4.2). Verwende dafür `#blockquote[]`:

```typst
#blockquote[
  „Die digitale Transformation verändert nicht nur die Geschäftsprozesse,
  sondern auch die Unternehmenskultur grundlegend. Unternehmen, die diesen
  Wandel nicht aktiv gestalten, riskieren langfristig ihre
  Wettbewerbsfähigkeit." @mustermann2024[S. 42]
]
```

Der Text wird automatisch links eingerückt und einzeilig formatiert — du musst dich um nichts kümmern.

> **Hinweis:** Die `[S. 42]`-Syntax nach `@key` übergibt die Seitenangabe an den Zitierstil. Die genaue Darstellung (z.B. „S." vs. „p.") hängt vom gewählten CSL-Stil ab.

---

# Optionale Features

## Englische Arbeiten

```typst
lang: "en",
```

Alle Verzeichnisüberschriften, die Ehrenwörtliche Erklärung und das KI-Verzeichnis wechseln automatisch auf Englisch. Der Zitierstil wechselt automatisch auf Harvard (Anglia Ruskin University) — die CSL-Datei ist im Template enthalten (HWR §6).

> **Tipp:** Setze `declaration-lang: "de"` damit die Ehrenwörtliche Erklärung auf Deutsch bleibt — das ist rechtlich die sichere Variante. Ob eine englische Erklärung akzeptiert wird, ist nicht verbindlich geklärt.

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

Das Template zeigt dann einen gelben Hinweis im PDF, der daran erinnert, dies mit dem Prüfer abzusprechen. Nach Absprache mit `warnings: false` unterdrückbar.

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

## Entwurfsmodus

Während der Arbeit kannst du ein Wasserzeichen einblenden, damit Entwürfe nicht versehentlich als finale Version eingereicht werden:

```typst
draft: true,
```

Auf jeder Seite erscheint ein grauer „ENTWURF"-Schriftzug (bei `lang: "en"` → „DRAFT"). Vor der Abgabe einfach auf `draft: false` setzen oder die Zeile entfernen.

---

## Digitale Unterschrift einbinden

Statt einer leeren Linie zum handschriftlichen Unterschreiben kannst du ein Bild deiner Unterschrift einbinden:

1. Unterschrift auf weißem Papier, einscannen oder abfotografieren
2. Als PNG oder SVG unter `images/` im Projektordner speichern
3. In `main.typ` beim Autoren-Eintrag ergänzen:

```typst
authors: (
  (name: "Max Mustermann", matrikel: "12345678", signature: image("images/signatur_max.png")),
),
```

Das Bild erscheint dann automatisch im Unterschriftsfeld der Ehrenwörtlichen Erklärung.

---

## Mermaid-Diagramme

Du kannst Mermaid-Diagramme direkt in Typst einbetten — ohne externe Tools. Das Package `mmdr` rendert Mermaid-Syntax nativ im Dokument:

```typst
#import "@preview/mmdr:0.2.1": mermaid

#figure(
  mermaid("graph TD
    A[Literaturrecherche] --> B[Hypothesenbildung]
    B --> C{Quantitativ?}
    C -->|Ja| D[Fragebogen]
    C -->|Nein| E[Interview]
  "),
  caption: [Forschungsprozess.],
)
```

Unterstützt werden 23 Diagramm-Typen: Flowcharts, Sequenzdiagramme, Klassendiagramme, ER-Diagramme, Gantt-Charts, Mindmaps, Pie Charts u.v.m.

> **Hinweis:** `mmdr` nutzt eine Rust-Implementierung von Mermaid — die visuelle Ausgabe kann in Randfällen leicht von mermaid.js abweichen. Wenn du pixelgenaue mermaid.js-Kompatibilität brauchst, rendere die Diagramme extern als SVG und binde sie per `image()` ein.

Details: [typst.app/universe/package/mmdr](https://typst.app/universe/package/mmdr)

---

## Pretty Mode

Du kannst ein dekoratives Deckblatt und einen Logo-Header aktivieren:

```typst
style: "pretty",
school-logo: image("images/school-logo.svg", height: 1.2cm),
company-logo: image("images/company-logo.svg", height: 1.2cm),
```

**Wichtig:** Der Pretty Mode ist **nicht in den HWR-Richtlinien vorgesehen**. Bitte vor Verwendung mit dem/der Betreuer/in absprechen. Das Template zeigt einen gelben Hinweis im PDF — nach Absprache mit `warnings: false` unterdrückbar.

Du kannst auch einzelne Features unabhängig aktivieren:
- `pretty-title: true` — nur dekoratives Deckblatt (Zierlinien, größerer Titel)
- `school-logo:` / `company-logo:` — nur Logo-Header im Haupttext

Standard ist `style: "compliant"` (richtlinienkonform).

---

# Referenz

## Hilfsfunktionen (im Text verwendbar)

Diese Funktionen kannst du in deinen Kapitel-Dateien verwenden:

| Funktion | Beschreibung |
|---|---|
| `#abk("KI")` | Abkürzung — beim ersten Mal expandiert, danach nur kurz |
| `#gls("key")` | Glossareintrag — beim ersten Mal expandiert, danach nur kurz |
| `#glspl("key")` | Glossareintrag in Pluralform |
| `#quelle()` | Quellenangabe „Eigene Darstellung" für Abbildungen/Tabellen |
| `#quelle(<bib-key>)` | Quellenangabe mit klickbarem Zitier-Link (empfohlen) |
| `#quelle(<bib-key>, "S. 42")` | Wie oben, mit Seitenangabe |
| `#quelle("Name", 2024)` | Quellenangabe als Freitext (kein Bib-Link) |
| `#blockquote[...]` | Eingerücktes, einzeiliges Blockzitat (HWR §3.4.2) |

Alle Funktionen sind nach dem Import in `main.typ` automatisch verfügbar. In Kapitel-Dateien müssen die benötigten Funktionen importiert werden:
```typst
#import "@preview/easy-wi-hwr:0.1.2": abk, gls, glspl, quelle, blockquote
```

---

## Gut zu wissen

**Zitierstil-Wahl:** Standard ist `"auto"` — das Template wählt automatisch APA für deutschsprachige und Harvard (Anglia Ruskin University) für englischsprachige Arbeiten. Die Harvard-CSL-Datei ist im Template enthalten. Wenn dein Betreuer einen anderen Stil vorgibt, kannst du eine eigene `.csl`-Datei aus dem [Zotero Style Repository](https://www.zotero.org/styles) herunterladen und per `read()` einbinden:
```typst
citation-style: read("mein-stil.csl"),
```
`read()` wird in `main.typ` aufgelöst — der Pfad ist also relativ zu `main.typ`.

**Abkürzungsverzeichnis erscheint automatisch**, aber nur wenn:
- Abkürzungen in `abbreviations:` eingetragen sind, UND
- `#abk("XY")` mindestens einmal im Text verwendet wird

Nicht verwendete Abkürzungen tauchen im Verzeichnis nicht auf.

**Abbildungs- und Tabellenverzeichnis** erscheinen erst ab 5 Einträgen (HWR-Anforderung). Das Template prüft das automatisch.

**Abgabe als Word + PDF:** Die HWR verlangt bei Bachelorarbeiten beide Formate. Das Template erzeugt nur PDF. Für die Word-Version gibt es mehrere Wege:
- **PDF → Word:** Adobe Acrobat (bestes Ergebnis), oder kostenlose Online-Tools (z.B. SmallPDF, iLovePDF) — Formatierung kann abweichen
- **Pandoc:** `pandoc main.typ -o arbeit.docx` — experimentell, verliert teils Formatierung
- **Copy-Paste:** PDF in Word öffnen (Word kann PDFs importieren) — oft die pragmatischste Lösung für einfache Dokumente

Die Word-Version dient erfahrungsgemäß vor allem der Archivierung — die Formatierung muss dabei in der Praxis nicht perfekt sein.

---

## Alle Parameter im Überblick

### Pflichtfelder

| Parameter | Beschreibung |
|---|---|
| `doc-type` | Art der Arbeit: `"ptb-1"`, `"ptb-2"`, `"ptb-3"`, `"hausarbeit"`, `"studienarbeit"`, `"bachelorarbeit"` |
| `title` | Titel der Arbeit |

**Autoren** — verwende *eine* der beiden Varianten:

| Variante | Parameter | Beschreibung |
|---|---|---|
| **Einzelperson** | `name` + `matrikel` | Kurzform: `name: "Max Mustermann"`, `matrikel: "12345678"` |
| **Gruppenarbeit** | `authors` | Array: `authors: ((name: "...", matrikel: "..."), (name: "...", matrikel: "..."))` |

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
| `ai-tools` | `()` | KI-Verzeichnis-Einträge — `(tool, usage, chapters, remarks?)` |
| `chapters` | `()` | Kapitel-Dateien via `include()` in gewünschter Reihenfolge |
| `appendix` | `()` | Anhang-Einträge: `(title: "...", content: include(...))` |
| `show-appendix-toc` | `false` | `true` = optionales Anhangsverzeichnis vor den Anhang-Einträgen (HWR §3.10) |
| `bibliography` | — | `bibliography("refs.bib")` — Titel wird automatisch gesetzt |
| `citation-style` | `"auto"` | Zitierstil: `"auto"` (DE → APA, EN → Harvard), `"apa"`, `"harvard-anglia-ruskin-university"`, oder `read("datei.csl")` |
| `heading-depth` | `4` | TOC-Tiefe 1–4 (max. 4 laut HWR) |
| `declaration-lang` | `auto` | Sprache der Ehrenwörtlichen Erklärung — `auto` folgt `lang`, `"de"` immer Deutsch (empfohlen — rechtssicher) |
| `city` | `"Berlin"` | Ort im Unterschriftsfeld der Ehrenwörtlichen Erklärung |
| `group-signature` | `auto` | `auto`/`true` = alle Autoren unterschreiben; `false` = nur erster Autor |
| `draft` | `false` | `true` = Wasserzeichen „ENTWURF"/„DRAFT" auf jeder Seite |
| `warnings` | `true` | `false` = gelbe Hinweisboxen im PDF unterdrücken (z.B. Pretty-Mode-Hinweis, nach Absprache mit Prüfer) |
| `style` | `"compliant"` | `"compliant"` (HWR-konform) oder `"pretty"` (dekorativ, mit Betreuer absprechen) |
| `school-logo` | `none` | Logo links im Seitenkopf, z.B. `image("images/logo.png")` |
| `company-logo` | `none` | Logo rechts im Seitenkopf |
| `pretty-title` | `none` | `true` = dekoratives Deckblatt; überschreibt `style:` für das Deckblatt |

### Felder im `authors`-Array

| Feld | Pflicht | Beschreibung |
|---|---|---|
| `name` | Ja | Vollständiger Name |
| `matrikel` | Ja | Matrikelnummer |
| `signature` | Nein | Unterschriften-Bild als Content, z.B. `image("images/signatur.png")` |

---

## Häufige Probleme

| Problem | Lösung |
|---|---|
| `doc-type "..." ist ungültig` | Wert muss exakt `"ptb-1"`, `"ptb-2"`, `"ptb-3"`, `"hausarbeit"`, `"studienarbeit"` oder `"bachelorarbeit"` sein |
| `supervisor ist Pflicht für...` | Für alle Typen außer `"bachelorarbeit"` müssen `supervisor:` und `company:` gesetzt sein |
| `confidential requires company:` | Sperrvermerk braucht den Firmennamen — `company:` setzen oder `confidential:` entfernen |
| `authors must be an array of dicts` | `authors:` muss ein Array sein: `authors: ((name: "...", matrikel: "..."),)` — bei einem Autor das Komma nach der Klammer nicht vergessen! |
| `chapters entries must use include()` | Keine String-Pfade verwenden. Richtig: `chapters: (include("kapitel/01.typ"),)` statt `chapters: ("kapitel/01.typ",)` |
| Times New Roman fehlt (Linux) | `sudo apt install ttf-mscorefonts-installer` |
| Abkürzung erscheint nicht im Verzeichnis | `#abk("XY")` muss im Text vorkommen — nur verwendete Abkürzungen erscheinen |
| KI-Verzeichnis fehlt | `ai-tools:` braucht mindestens einen Eintrag; bei `ai-tools: ()` erscheint kein Verzeichnis |
| Abbildungsverzeichnis fehlt | Erscheint erst ab 5 Abbildungen (HWR-Anforderung) |
| Kapitel erscheint nicht im PDF | Prüfe ob die Datei in der `chapters:`-Liste in `main.typ` eingetragen ist |
| Import-Fehler bei `include()` | Pfade in `chapters:` sind relativ zu `main.typ` — `include("kapitel/01_einleitung.typ")` |
| `signature muss image-Content sein` | Verwende `signature: image("images/sig.png")` statt `signature: "images/sig.png"` |
| Alle Seiten doppelt / seltsame Formatierung | Nur ein `#show: hwr.with(...)` Block pro Datei — kein zweites `#show:` und kein Text davor |
| `#abk()` / `#gls()` in Kapitel-Datei funktioniert nicht | In jeder Kapitel-Datei muss `#import "@preview/easy-wi-hwr:0.1.2": abk` stehen (oder welche Funktionen du nutzt) |
| Zitierstil-Datei wird nicht gefunden | `citation-style: read("mein-stil.csl")` — Pfad ist relativ zu `main.typ`. Datei muss im selben Ordner liegen |
| Anhang-Nummerierung zeigt A, B, C statt 1, 2, 3 | Nutze die eingebaute Anhang-Funktion via `appendix:` Parameter — nicht manuell nummerieren |
| PDF zeigt keine Seitennummern | Prüfe ob nur ein `#show: hwr.with(...)` vorhanden ist und kein `set page(numbering: none)` im Text steht |

---

## Lokale Entwicklung/Kompilierung (für Template-Entwickler)

Wenn du am Template selbst arbeitest (nicht als Nutzer), musst du die Imports umschalten:

**Schritt 1: Imports auf lokal umstellen**

In `template/main.typ`:
```typst
// Diese Zeile auskommentieren:
// #import "@preview/easy-wi-hwr:0.1.2": hwr, abk, gls, glspl, quelle, blockquote
// Diese Zeile aktivieren:
#import "../lib.typ": hwr, abk, gls, glspl, quelle, blockquote
```

In `template/kapitel/01_einleitung.typ` (und allen anderen Kapitel-Dateien die `abk` nutzen):
```typst
// #import "@preview/easy-wi-hwr:0.1.2": abk
#import "../../lib.typ": abk
```

**Schritt 2: Kompilieren**

```bash
# Repository klonen:
git clone https://github.com/lultoni/easy-wi-hwr.git
cd easy-wi-hwr

# Template kompilieren (--root . ist nötig, damit Typst ../lib.typ auflösen kann):
typst compile --root . template/main.typ

# Live-Preview:
typst watch --root . template/main.typ
```

**Vor dem Commit / Publish:** Imports wieder auf `@preview/` zurückschalten, damit Nutzer keine Fehler bekommen.

---

## Lizenz

MIT — siehe LICENSE
