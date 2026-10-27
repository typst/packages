<h1 align="center">cvut-thesis</h1>

<p align="center">
  <strong>Unofficial thesis layout for ČVUT (CTU in Prague)</strong><br>
</p>

<p align="center">
  <a href="https://typst.app/universe/package/cvut-thesis"><img alt="Package: @preview/cvut-thesis" src="https://img.shields.io/badge/package-@preview%2Fcvut--thesis-239dad?logo=typst&logoColor=white"></a>
  <img alt="Typst 0.11+" src="https://img.shields.io/badge/typst-0.11%2B-239dad?logo=typst&logoColor=white">
  <a href="LICENSE"><img alt="License: MIT-0" src="https://img.shields.io/badge/license-MIT--0-blue.svg"></a>
</p>

<p align="center">
  <img src="thumbnail.png" alt="Preview of the cvut-thesis Typst template" width="50%">
</p>

`cvut-thesis` is an unofficial Typst template for qualification theses at the Czech Technical University in Prague. It currently focuses on the Faculty of Electrical Engineering (`fel-thesis`).

> **Note:** This template is unofficial and not endorsed by ČVUT. Always verify the final PDF against your faculty's current thesis requirements before submitting.

## Features
- Nice cover page with logo, study branch, thesis type, author, supervisor/details grid, and submission date.
- Declaration of authorship page (in Czech) with a signature line.
- Czech and English abstract pages with localized keywords.
- Styled table of contents via `fel-toc`.
- Sensible thesis layout: 11pt serif text, justified paragraphs, numbered headings, first-line indentation, and clean figures/code-blocks.
- Optional print binding gutter with wider inside margin.
- Template project with ČVUT logo and ISO690-numeric citation style.

## Quick start
In the [Typst web app](https://typst.app), click **Start from template** and search for `cvut-thesis`.

Or initialize a fresh project locally with the Typst CLI:
```sh
typst init @preview/cvut-thesis:0.1.0 my-thesis
cd my-thesis
typst watch main.typ
```
Typst will copy the starter project (from the `template` folder) and keep recompiling the PDF whenever you make changes.

## Usage
A minimal thesis starts with a single `show` rule:
```typ
#import "@preview/cvut-thesis:0.1.0": fel-thesis

#show: fel-thesis.with(
  title: "Velmi zajímavá studie",
  subtitle: "Bakalářská práce",
  author: "Jan Novák",
  details: (
    "Vedoucí": "Prof. Jiří Dvořák",
    "Školitel-specialista": "František Vomáčka, Ph.D.",
    "Studijní program": "Enterprise architektury",
  ),
  date: "Květen 2026",
  abstract-cz: [
    This is the Czech abstract of the thesis.
  ],
  abstract-en: [
    This is the English abstract of the thesis.
  ],
  keywords-cz: ("pes", "a", "kočička"),
  keywords-en: ("dog", "and", "cat"),
  branch: "Obor Softwarové inženýrství a technologie",
  logo: image("assets/cvut-logo.svg"),
)

= První kapitola
// TODO: start writing here
```

The bundled starter also includes a bibliography call:
```typ
#bibliography(
  "references.yaml",
  style: "assets/iso690-numeric-brackets-cs.csl",
)
```

## Configuration
`fel-thesis` accepts the following named arguments:

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | `str` | `"REPORT TITLE"` | Thesis title shown on the cover page and in PDF metadata. |
| `subtitle` | `str` | `"REPORT SUBTITLE"` | Thesis type or subtitle, e.g. `"Bachelor's Thesis"`. |
| `author` | `str` | `"AUTHOR NAME"` | Author name shown on the cover page and in PDF metadata. |
| `details` | `dictionary` | `()` | Label/value pairs displayed on the cover page, such as supervisor or programme. |
| `date` | `str` | `"DATE OF SUBMISSION"` | Submission month/year or full date. |
| `sign-date` | `datetime` | `datetime.today()` | Date shown on the declaration of authorship page. |
| `abstract-cz` | `content` / `str` | `"ABSTRACT TEXT CZ"` | Czech abstract. |
| `abstract-en` | `content` / `str` | `"ABSTRACT TEXT EN"` | English abstract. |
| `keywords-cz` | `array` | `("KEYWORDS", "CZ")` | Czech keywords, joined with commas. |
| `keywords-en` | `array` | `("KEYWORDS", "EN")` | English keywords, joined with commas. |
| `university` | `str` | `"Fakulta elektrotechnická, ČVUT v Praze"` | Faculty/university label on the cover page. |
| `branch` | `str` | `"YOUR STUDY BRANCH"` | Study branch shown below the faculty name. |
| `toc-title` | `str` | `"Obsah"` | Title of the table of contents page. |
| `logo` | `content` / `none` | `none` | Logo content, typically `image("assets/cvut-logo.svg")`. |
| `gutter` | `bool` | `false` | Enables binding-friendly inside/outside margins. |
| `body` | `content` | required | The actual thesis content after front matter. |

## Exported helpers
| Helper | Use it for |
| --- | --- |
| `fel-thesis` | Full FEL thesis structure: cover, declaration, abstracts, table of contents, page numbering, and body. |
| `fel-cover` | Standalone FEL-style cover page. |
| `fel-toc` | Standalone styled table of contents. |

## Project structure
```text
cvut-thesis/
├─ lib.typ                  # public exports
├─ typst.toml               # typst package manifest
├─ src/
│  ├─ core.typ              # shared CTU layout primitives
│  └─ faculties/
│     └─ fel.typ            # FEL cover, TOC, and thesis wrapper
└─ template/
   ├─ main.typ              # starter thesis (showcase)
   ├─ references.yaml       # hayagriva bibliography example
   └─ assets/
      ├─ cvut-logo.svg
      └─ iso690-numeric-brackets-cs.csl
```

## License
Original code, documentation, and starter files: [MIT-0](LICENSE).

Third-party assets are licensed under [CC-BY-SA-3.0](https://creativecommons.org/licenses/by-sa/3.0/):
- `template/assets/iso690-numeric-brackets-cs.csl` - Jiří Kratochvíl and Libor Ansorge ([source](template/assets/iso690-numeric-brackets-cs.csl)).
- `template/assets/cvut-logo.svg` - České vysoké učení technické v Praze ([source](https://cs.wikipedia.org/wiki/Soubor:CVUT_znak.svg)). Trademark restrictions still apply.
