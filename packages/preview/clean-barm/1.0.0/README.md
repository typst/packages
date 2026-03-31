# clean-barm

Dieses git Repository enthält das [Typst](https://typst.app/) Template für die Ausarbeitungen an der [Berufsakademie Rhein-Main](https://studenten.ba-rm.de/).
Das ursprüngliche Template wurde von [GolemT](https://github.com/GolemT/ba-template) erstellt, dieses Repository enthält eine vereinheitlichte und überarbeitete Version davon und soll im Typst Universe veröffentlicht werden.

Das Repository enthält derzeit Templates für die folgenden Dokumente:
- Paper (Wissenschaftliches Arbeiten)
- TPT III
- Exposé
- Bachelor Thesis

## Setup

Allgemein ist das Template mittels `typst init @preview/clean-barm` nutzbar.

Für rein lokale Setups und zur Weiterentwicklung
- Linux: `${XDG_DATA_HOME:-~/.local/share}/typst/packages/local/clean-barm/1.0.0`
- MacOS: `~/Library/Application Support/typst/packages/local/clean-barm/1.0.0`
- Windows: `%APPDATA%\typst\packages\local\clean-barm\1.0.0`

geklont und mittels `typst init @local/clean-barm:1.0.0` initialisiert werden

Alternativ dazu kann natürlich auch einfach das Repository an einen Wort der Wahl geklont oder von [als zip](https://git.thebread.dev/theBreadCompany/ba-template/archive/main.zip) heruntergeladen und extrahiert werden.

Bei der lokalen Nutzung mittels `typst` erfolgt die Kompilierung weiterhin mittels `typst w main.typ`.

Die in der main.typ hinterlegten Assets nutzen `prequery`, um die Assets nicht im Paket selbst hinterlegen zu müssen (was an der Lizenz scheitern würde). 
Entweder kann das Tool installiert werden, um mittels `prequery main.typ` die benötigten Ressourcen automatisch zu pullen, oder manuell die Bilder heruntergeladen und abgelegt werden.
*Infolge dieses Aufbaus kompiliert das erzeugte Template nicht automatisch!* Eine Fallback Option mit Erklärung ist deshalb ganz oben im Dokument hinterlegt.

### Neues Projekt in Typst anlegen

### Projektfiles auswählen

Für alle normale Semianrarbeiten der BA reicht das Template "Paper". Für Bacherlorarbeiten, Expose oder TPT III sollten die anderen Templates genutzt werden.

### Projektfiles hochladen

Solange das Paket noch nicht veröffentlicht wurde müssen alle Dateien im Ordner des Templates hochgeladen werden. Dazu kann man im Typst Projekt über den "Hochladen" Knopf alle Dateien im Explorer auswählen.

Sobald die Veröffentlichung abgeschlossen ist kann auch in der Web-App das Template instanziiert werden.

## Schreiben in Typst

### Setzen der Hauptattribute

Jede main.typ fängt mit einem Definitionsblock des Templates an. In diesem können Titel, Authoren, Abgabedatum, Modul, Bild des Deckblatts definiert werden. Zudem kann hier durch einen Bool wert gesetzt werden, ob bestimmte Blöcke im PDF generiert werden sollen. So kann man z.B. das Codeverzeichnis ausblenden wenn man keinen Code in seiner Arbeit hat. Hier eine Übersicht der Attribute:

<details>
  <summary>Thesis</summary>
   
  ```typst
  #show: Thesis.with(
    //language: "de", // Standard
    title: "Titel der Arbeit",
    author: "Max Mustermann",
    keywords: ("Thesis", "Bachelor", "..."),
    description: "Thesis über xyz",
    degree-program: "Angewandte Informatik",
    study-group: "AI-WS23_III",
    student-id: "1234567",
    contact-details: (
      "Musterstraße 1",
      "12345 Musterstadt",
      "max.mustermann@email.com",
    ),
    academic-reviewer: "Alice",
    company-reviewer: "Bob",
    submission-date: "10.06.2026",
    university-logo: image("../images/BA_Logo.jpg", width: auto),
    company-logo: image("../images/DB_Logo.png", height: 3fr),
    show-list-of-figures: true,
    show-list-of-tables: true,
    show-list-of-code: true,
    acronyms: (:), // leeres Dictionary
    appendix: none,
    glossary: (:), // leeres Dictionary
    bibliography: none,
    //restriction-notice: "" // hat internen Standardtext
    //foreword: "",
    //gendering-note: "", // hat internen Standardtext
  )
  ```
</details>

<details>
  <summary>Exposé</summary>

  ```typst
  #show: Expose.with(
    title: "Titel der Arbeit",
    author: "Max Mustermann",
    study-group: "AI-WS23_III",
    student-id: "123456",
    contact-details: (
      "Musterstraße 1",
      "12345 Musterstadt",
      "max.mustermann@email.com",
    ),
    keywords: ("PDF", "Ausarbeitung"),
    date-of-colloquium: "03.12.2025",
    submission-date: "27.11.2025",
    academic-reviewer: "Alice",
    company-reviewer: "Bob",
    university-logo: logo(width: auto),
    module: [Theorie-Praxis-Anwendung II],
    show-list-of-figures: true,
    show-list-of-tables: true,
    show-list-of-code: true,
    acronyms: (
      API: "Application Programming Interface",
      HTML: "Hypertext Markup Language",
    ),
    appendix: include "./anhang.typ",
    glossary: (
      "API": "Application Programming Interface",
      "Typst": "Eine Markup-Sprache für die Dokumentenerstellung",
    ),
    bibliography: bibliography(
      title: none,
      "refs.bib",
    ),
    //restriction-notice: "" // hat internen Standardtext
    //foreword: "",
    //gendering-note: "", // hat internen Standardtext
  )
  ```
</details>

<details>
  <summary>TPT</summary>

  ```typst
  #show: TPT.with(
    title: "Titel der Arbeit",
    authors: (
      (name: "Max Mustermann", student-id: "1234567"),
    ),
    study-group: "AI-WS23_III",
    keywords: ("PDF", "Ausarbeitung"),
    description: "",
    date: "01.01.2024",
    university-logo: logo(width: auto),
    modul: [Theorie-Praxis-Anwendung II],
    pre-thesis: false, // only for TPT3
    show-list-of-figures: true,
    show-list-of-tables: true,
    show-list-of-code: true,
    acronyms: (
      API: "Application Programming Interface",
      HTML: "Hypertext Markup Language",
    ), 
    appendix: include "./anhang.typ",
    glossary: (
      "API": "Application Programming Interface",
      "Typst": "Eine Markup-Sprache für die Dokumentenerstellung",
    ),
    bibliography: bibliography(
      title: none,
      "refs.bib",
    ),
    //restriction-notice: "" // hat internen Standardtext
    //foreword: "",
    //gendering-note: "", // hat internen Standardtext
  )
  ```
</details>

<details>
  <summary>Paper</summary>

  ```typst
  #show: Paper.with(
    title: "Titel der Arbeit",
    authors: (
      (name: "Max Mustermann", student-id: "1234567"),
    ),
    study-group: "AI-WS23_III",
    keywords: ("PDF", "Ausarbeitung"),
    description: "",
    date: "01.01.2024",
    university-logo: logo(width: auto),
    modul: [Theorie-Praxis-Anwendung II],
    pre-thesis: false, // only for TPT3
    show-list-of-figures: true,
    show-list-of-tables: true,
    show-list-of-code: true,
    acronyms: (
      API: "Application Programming Interface",
      HTML: "Hypertext Markup Language",
    ), 
    appendix: include "./anhang.typ",
    glossary: (
      "API": "Application Programming Interface",
      "Typst": "Eine Markup-Sprache für die Dokumentenerstellung",
    ),
    bibliography: bibliography(
      title: none,
      "refs.bib",
    ),
    //restriction-notice: "" // hat internen Standardtext
    //foreword: "",
    //gendering-note: "", // hat internen Standardtext
  )
  ```

</details>

Sollte die Liste mit Akronymen oder das Glossar zu groß werden, kann auch auch im Stil des Anhangs ein separates Dokument angelegt und die entsprechenden Einträge ausgelagert werden:

<details>
  <summary>main.typ + acronyms.typ</summary>

  acronyms.typ:

  ```typst
  #let Acronyms = (
    API: "Application Programming Interface",
    HTML: "Hypertext Markup Language",
  )
  ```

  main.typ 

  ```typst 
  #import "acronyms.typ": Acronyms
  #show Thesis.show(
    acronyms: Acronyms,
  )
  ```
</details>

Mehr Demo Code ist im Template sowie [in der Typst Dokumentation](https://typst.app/docs/tutorial/) zu finden.
