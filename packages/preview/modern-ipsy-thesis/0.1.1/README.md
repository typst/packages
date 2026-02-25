# IPSY Bachelor-/Masterarbeitsvorlage für Typst

[🇬🇧 See here for an English version of the README.](README-en.md)

[![Die Titelseite der FNW-Vorlage.](thumbnails/1.png)](https://github.com/xkevio/ipsy-thesis/blob/af999fddac36ec208507fffbc20f1e5db5cef7a8/guide/guide-de.pdf)

## Erste Schritte

Um diese Vorlage zu benutzen, importiere diese wie folgt und benutze den `#show`-Befehl mit den gewünschten Parametern. Danach kannst du mit dem gewohnten Typst-Syntax anfangen zu schreiben!

```typ
#import "@preview/modern-ipsy-thesis:0.1.1": *

#show: ipsy.with(
  title: [Meine Bachelorarbeit],
  author: (name: "Max Mustermann", mail: "max.mustermann@ovgu.de", mat-num: 222222),
  // ... und weitere Parameter (siehe unten) ...
)
```

## Benutzung

Eine Auflistung _aller_ Parameter befindet sich im folgendem Abschnitt oder im [Beispieldokument](https://github.com/xkevio/ipsy-thesis/blob/af999fddac36ec208507fffbc20f1e5db5cef7a8/guide/guide-de.pdf):

```typ
#show: ipsy.with(
  /// The title of your thesis.
  /// -> content
  title: [Titel],
  /// The author data (your name, mail and student number).
  /// -> dictionary
  author: (name: "Vorname Nachname", mail: "vorname.nachname@ovgu.de", mat-num: 123456),
  /// The optional abstract of your thesis.
  /// -> content | none
  abstract: none,
  /// The optional appendix of your thesis.
  /// -> content | none
  appendix: none,
  /// The statement of authorship.
  /// -> content | none
  legal: none,
  /// The logo(s) of your faculty for the title page.
  /// -> content | none
  logo: move(dy: -0.5em, image("images/fnw_logo.svg")),
  /// The thesis type (bachelor, master, PhD, etc...).
  /// -> content
  thesis-type: "Bachelorarbeit",
  /// The academic title you shall receive.
  /// -> content
  academic-title: "Bachelor of Science (B.Sc.)",
  /// The study course for which this thesis is in fullfilment of.
  /// -> content
  study-course: "Psychologie",
  /// The institute or department for which this thesis is written.
  /// -> content
  institute: "Institut für Psychologie",
  /// The specific chair or subdepartment.
  /// -> content
  chair: "Lehrstühle für Biologische Psychologie und Neuropsychologie",
  /// The list of reviewers.
  /// -> array
  reviewers: (),
  /// The (optional) bibliography.
  /// -> bibliography | none
  bibliography: none,
  /// The submission date (either as `datetime` or manually).
  /// -> datetime | content
  date: datetime(year: 9999, month: 4, day: 1),
  /// The language of your thesis (for hyphenation and spell-check).
  /// -> string
  lang: "de",
  /// The space between lines.
  /// -> length
  line-spacing: 0.65em,
  /// Whether to include the list of tables or figures in your outline.
  /// -> boolean
  extra-outlined: false,
  /// Whether to add the current section title to the header.
  /// -> boolean
  section-title: false,
  /// The color of links to web pages.
  /// -> color
  link-color: black
)
```

## Schriftarten und Fakultätslogos

Du brauchst die folgenden (frei erhältlichen) Schriftarten:
- [`TeX Gyre Heros`](https://ctan.org/pkg/tex-gyre-heros)
- [`Fira Mono`](https://fonts.google.com/specimen/Fira+Mono)

Das deutsche FNW-Logo ist bereits vorhanden (die 0-BSD Lizenz gilt nicht für dieses Logo). Falls du dieses anpassen möchtest, kannst du die anderen Logos hier finden: https://www.cd.ovgu.de/Fakult%C3%A4ten.html
