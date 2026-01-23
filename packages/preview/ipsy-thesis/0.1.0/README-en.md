# IPSY Bachelor or Master Thesis Template for Typst

[🇩🇪 Klick hier für die deutsche Version der README.](README.md)

[![The title page of the FNW thesis template.](thumbnails/2.png)](guide/guide-en.pdf)

## Getting Started

To start using this template, simply import it as shown below and use a `#show`-rule with the appropriate parameters to apply the styling.
Afterwards, you can start writing with the usual Typst syntax!

```typ
#import "@preview/ipsy-thesis:0.1.0": *

#show: ipsy.with(
  title: [My Thesis Title],
  author: (name: "Max Mustermann", mail: "max.mustermann@ovgu.de", mat-num: 222222),
  // ... and more parameters (see below) ...
)
```

## Usage

A list of _all_ parameters is given in the following section or in the [example guide](guide/guide-en.pdf):

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

## Fonts and Corporate Design

You will need the following (free and open source) fonts:

- [`Tex Gyre Heros`](https://ctan.org/pkg/tex-gyre-heros)
- [`Fira Mono`](https://fonts.google.com/specimen/Fira+Mono)

The German FNW logo is already included. If you wish to change it, you can find the other logos here: https://www.cd.ovgu.de/Fakult%C3%A4ten.html.
