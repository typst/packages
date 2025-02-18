# HTL Rennweg Diplomarbeitsvorlage

> [!IMPORTANT]
> If you are not a student of HTL Rennweg, this template will be of little use to you.

Dieses Template dient als Vorlage für ein Diplomarbeitsbuch an der HTL Rennweg und orientiert
sich an der Word-Vorlage mit dem Stand 2024/25. Es gibt jedoch Abweichungen, für welche sich
absichtlich entschieden wurde. Dies beinhalten vor allem die Schriftarten. Es wird versucht,
ein einheitliches Gesamtbild zu schaffen.

## Setup

To adhere to the official style of the book, all template options should be set according to the following template.

```typ
#import "@preview/htl3r-da:1.0.0" as htl3r

#show: htl3r.diplomarbeit.with(
  title: "Mein DA-Titel",
  subtitle: "mit kreativem Untertitel",
  department: "ITN", // kann eine Auswahl sein aus: ITN, ITM, M
  school-year: "2024/2025",
  authors: (
    (name: "Max Mustermann", supervisor: "Peter Professor"),
    (name: "Andreas Arbeiter", supervisor: "Bernd Betreuer"),
    (name: "Theodor Template", supervisor: "Bernd Betreuer"),
  ),
  abstract-german: [#include "text/kurzfassung.typ"],
  abstract-english: [#include "text/abstract.typ"],
  supervisor-incl-ac-degree: (
    "Prof, Dipl.-Ing. Peter Professor",
    "Prof, Dipl.-Ing. Bernd Betreuer",
  ),
  sponsors: (
    "Scherzartikel GmbH",
    "Ottfried OT-Handels GmbH",
  ),
  date: datetime.today(),
  print-ref: true,
  generative-ai-clause: none,
  abbreviation: yaml("abbr.yml"),
  bibliography-content: bibliography("refs.yml", title: [Literaturverzeichnis])
)
```

## Template functions
For an overview of the functions see the [manual](docs/manual.pdf).

## Installation (for devs)

The Justfile provides useful recipes for installation/development.

The basic setup is as follows (requires "git" and "just"):

```bash
git clone https://github.com/HTL3R-Typst/htl3r-da
just install-preview # to install into the "preview" namespace
```

Now you are able to compile documents using the template system-wide.

## License

Files in the directory `src/lib/assets/htl3r-citestyle` are licensed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)
as compatible with the original work licensed under [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/).

Other files in this project are licensed under [0BSD](https://opensource.org/license/0bsd).
