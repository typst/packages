# oh-my-gost

Typst template for student research reports following `ГОСТ 7.32-2017`.
It supports Russian and English structural labels while keeping the same GOST
page layout and typography defaults.

## Features

- A4 page format.
- Margins: left `30mm`, right `15mm`, top and bottom `20mm`.
- Main text size `14pt`.
- Paragraph indent `1.25cm`.
- 1.5-style line spacing.
- Title page without a visible page number.
- Russian and English labels via `lang: "ru"` or `lang: "en"`.
- BibTeX bibliography support through `bibliography-file: "references.bib"`.

## Usage

For local development in this repository:

```typst
#import "lib.typ": gost-report

#show: gost-report.with(
  lang: "ru",
  title: "Название работы",
  author: "Иванов И. И.",
  group: "M34011",
  institution: "Название университета",
  city: "Москва",
  year: "2026",
  supervisor: "Петров П. П.",
  keywords: ("ГОСТ 7.32-2017", "Typst"),
  bibliography-file: "references.bib",
)
```

When installed as a Typst Universe package, use:

```typst
#import "@preview/oh-my-gost:0.1.0": gost-report
```

Before the package is accepted into Typst Universe, you can test the same
`@preview` import locally on Linux:

```sh
mkdir -p ~/.local/share/typst/packages/preview/oh-my-gost/0.1.0
cp -R typst.toml lib.typ template examples README.md LICENSE thumbnail.png ~/.local/share/typst/packages/preview/oh-my-gost/0.1.0/
```

Then create a new report from the starter:

```sh
typst init @preview/oh-my-gost:0.1.0 my-report
cd my-report
typst compile main.typ
```

## Bibliography

The template expects a BibTeX `.bib` file when `bibliography-file` is set.

```bibtex
@book{knuth1984texbook,
  author = {Donald E. Knuth},
  title = {The TeXbook},
  year = {1984},
  publisher = {Addison-Wesley}
}
```

Cite entries in the body with Typst's normal citation syntax:

```typst
This statement cites a source @knuth1984texbook.
```

Set `bibliography-file: none` to omit the generated references section.

## Compile Examples

```sh
typst compile --root . examples/student-report-ru.typ
typst compile --root . examples/student-report-en.typ
```

The starter template uses package-style import and is meant for `typst init`
after installing the package locally.

## Notes

This template is intended for practical student reports. It follows the core
layout and structure of `ГОСТ 7.32-2017`, but it is not a legal certification
tool. Always check local university or department requirements when they add
stricter rules.
