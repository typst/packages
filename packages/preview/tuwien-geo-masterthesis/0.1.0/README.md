# The `tuwien-geo-masterthesis` Package

[![Dynamic TOML Badge](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2FTUW-GEO%2Ftuwien-geo-masterthesis%2Frefs%2Fheads%2Fmain%2Ftypst.toml&query=%24.package.version&prefix=v&logo=typst&label=template&color=239DAD)](https://typst.app/universe/package/tuwien-geo-masterthesis) [![MIT License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/TUW-GEO/tuwien-geo-masterthesis/blob/main/LICENSE) [![Test Status](https://github.com/TUW-GEO/tuwien-geo-masterthesis/actions/workflows/ci.yml/badge.svg)](https://github.com/TUW-GEO/tuwien-geo-masterthesis/actions/workflows/ci.yml)

*"The official template for Mastertheses at the Geo Department of TU Wien."*

## Getting Started

```typ
#import "@preview/tuwien-geo-masterthesis:0.1.0": *

#let info = (
  ..default-info,
  title: "My Thesis Title",
  author: "Max Mustermann",
  student-id: "12345678",
  supervisor: "Prof. Dr. Supervisor Name",
)

#show: thesis.with(info: info, lang: "en")

#make-title-page(info)
#make-declaration(info)
#make-abstract(
  en: [English abstract.],
  de: [Deutsche Kurzfassung.],
)
// #make-acknowledgements([Thanks to ...])  // optional

#outline()
= Introduction
...
```

## Features

- TU Wien branded title page (logo, blue colour scheme)
- Bilingual declaration of authorship (German + English)
- Abstract pages (English + German)
- Optional acknowledgements page
- Running header with chapter title, page counter in footer
- Glossary support via `glossarium`
- Configurable degree type: `"Diplomarbeit"`, `"Master"`, `"Bachelor"`

## Customization Options

Key parameters available:

```typ
#show: thesis.with(
  info: default-info,
  lang: "de",
  eq-numbering: "(1.1)",
  main-font: ("New Computer Modern Sans", "PT Sans"),
  page-paper: "a4",
  page-margins: (top: 22mm, bottom: 22mm, left: 24mm, right: 24mm),
)
```

`default-info` covers `title`, `author`, `student-id`, `degree`, `study-program`, `department`, `faculty`, `university`, `supervisor`, `co-supervisor`, `cooperation`, `location`, and `date` — see [the manual PDF](https://github.com/TUW-GEO/tuwien-geo-masterthesis/releases/latest/download/tuwien-geo-masterthesis-manual.pdf) for the full reference. The package also exports the colours `tu-blue` (`rgb("#006699")`) and `forrest-green` (`rgb(0%, 27%, 13%)`).

## Contributing

Contributions are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md) for setup, style, and release process.

## Local Installation

For development purposes you might want to install the template locally on your machine.
In this repository the local installation is handled by [`gotpm`](https://github.com/npikall/gotpm).
You can run the following commands, to test changes you have made to the template.

```bash
gotpm install            # install as @local/tuwien-geo-masterthesis:0.1.0
gotpm install -n preview # install as @preview/tuwien-geo-masterthesis:0.1.0
```
