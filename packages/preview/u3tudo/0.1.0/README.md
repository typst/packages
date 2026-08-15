# u3tudo

An unofficial Typst template for PhD theses at TU Dortmund University, inspired by the
[LaTeX TUDoThesis](https://github.com/maxnoe/tudothesis) class.

## Quick Start

### Using `typst init`

```sh
typst init @preview/u3tudo
```

This creates a new directory with all template files.

### Manual setup

Clone this repository and start editing `template/thesis.typ`:

```sh
git clone https://github.com/jspeer/u3tudo.git
cd u3tudo
typst compile --root . template/thesis.typ
```

## Usage

Edit `thesis.typ` to set your thesis metadata:

```typst
#show: thesis.with(
  title: "Your PhD Thesis Title",
  author: "Your Name",
  birthdate: "01.01.1990",
  birthplace: "Hometown",
  date: "August 2025",
  first-corrector: "Prof. Dr. First Reviewer",
  second-corrector: "Prof. Dr. Second Reviewer",
  examination-committee-chair: "Prof. Dr. Committee Chair",
  phd-representative: "Dr. PhD Representative",
  submission-date: "1. August 2025",
  defense-date: "1. October 2025",
  tucolor: true,           // TU green accent color
  binding-correction: 12mm, // binding offset
  two-sided: false,         // double-sided printing (binding correction on inner side, running heading and page number on outer side)
  logo: read("logos/tu-logo.svg", encoding: none),
)
```

### Document structure

```typst
// Front matter (Roman numeral pages)
#include "content/00_abstract.typ"
#pagebreak()
#outline(title: [Contents])

// Main matter (Arabic page numbers)
#mainmatter
#include "content/01_introduction.typ"
#include "content/02_chapter.typ"

// Appendix (lettered chapters A, B, C, ...)
#appendix
#include "content/appendix.typ"

// Back matter
#backmatter
#bibliography("references.bib", title: [References], style: "ieee")
#include "content/acknowledgements.typ"
```

### Helper functions

- `#mainmatter` — switch to Arabic page numbering, reset heading counter
- `#appendix` — switch to lettered chapters (A, B, C, ...), reset heading counter
- `#backmatter` — switch to back matter (unnumbered headings)

### Headings

- Main matter chapters: `= Chapter Title` (numbered 1, 2, 3, ...)
- Sections: `== Section` (numbered 1.1, 1.2, ...)
- Front matter (abstract, Kurzfassung): use unnumbered, non-outlined headings:
  ```typst
  #heading(level: 1, numbering: none, outlined: false)[Abstract]
  ```
- Back matter (acknowledgements): use unnumbered, outlined headings:
  ```typst
  #heading(level: 1, numbering: none, outlined: true)[Acknowledgements]
  ```
- Appendix chapters: use lettered headings:
  ```typst
  #heading(level: 1, numbering: "A.1.1")[Appendix Title]
  ```

## Features

- Title page and assessment page (Gutachterseite) following TU Dortmund PhD thesis conventions
- Roman numeral page numbering for front matter, Arabic for main matter
- Chapter-based numbering for figures, tables, and equations
- Lettered appendix chapters (A, B, C, ...)
- Running headers with current chapter title and header line
- Optional TU green accent color (`tucolor: true`)
- Configurable binding correction
- Optional double-sided printing (`two-sided: true`): binding correction on the inner side, running heading and page number on the outer side
- Bibliography support via Typst's built-in `bibliography()`
- Table of contents (chapters and sections)

## Template parameters

| Parameter                  | Default                         | Description                              |
| -------------------------- | ------------------------------- | ---------------------------------------- |
| `title`                    | `""`                            | Thesis title                             |
| `author`                   | `""`                            | Author name                              |
| `birthdate`                | `""`                            | Author's birth date                       |
| `birthplace`               | `""`                            | Author's birth place                      |
| `date`                     | `""`                            | Date string (e.g. "August 2025")          |
| `faculty`                  | `"Fakultät Physik"`             | Faculty name                              |
| `university`               | `"Technische Universität Dortmund"` | University name                      |
| `city`                     | `"Dortmund"`                    | City for the title page                   |
| `degree`                   | `"Dr. rer. nat."`               | Academic degree                           |
| `first-corrector`          | `""`                            | First reviewer (Erstgutachter)            |
| `second-corrector`         | `""`                            | Second reviewer (Zweitgutachter)          |
| `examination-committee-chair` | `""`                         | Examination committee chair               |
| `phd-representative`       | `""`                            | PhD representatives' representative       |
| `submission-date`          | `""`                            | Date of submission                        |
| `defense-date`             | `""`                            | Date of oral defense                      |
| `tucolor`                  | `false`                         | Use TU green accent color                 |
| `binding-correction`       | `12mm`                          | Binding correction offset                 |
| `two-sided`                | `false`                         | Double-sided printing (binding correction on inner side, running heading and page number on outer side) |
| `logo`                     | `none`                          | Logo image bytes (e.g. `read("logos/tu-logo.svg", encoding: none)`; `none` = no logo)|

## License

MIT
