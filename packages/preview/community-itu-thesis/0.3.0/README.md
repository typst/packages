# ITU Thesis Template (Typst) · `community-itu-thesis`

A Typst template for graduate (master's and doctoral) theses at Istanbul
Technical University (İTÜ), ported from the official LaTeX template (`itutez.cls`,
template v2.0.0, October 2026 — generated from the official MS Word templates). The thesis output itself is in Turkish (with optional
English language mode), since that is the intended audience.

> ⚠️ **Unofficial community port.** This package is not officially endorsed by
> Istanbul Technical University; it is an independent, volunteer adaptation of
> the official LaTeX class. Always verify the output against the current
> official ITU thesis guidelines before submitting your thesis.

## Quick start

```bash
typst init @preview/community-itu-thesis:0.3.0 my-thesis
cd my-thesis
typst watch main.typ
```

This creates a working sample project. Edit the information in `main.typ` to
match your own thesis.

## Features

- Outer cover + inner covers in both languages (official v2 layout)
- Jury approval page and academic integrity declaration
- Dedication, Preface, Table of Contents, Abbreviations, Symbols
- List of Tables and List of Figures (automatic, captions above, figures numbered per chapter)
- Özet / Abstract (Turkish and English abstracts)
- Roman page numbers (i, ii, …) in front matter, Arabic (1, 2, …) in the body
- Numbered chapters (“1. …”, with subheadings “1.1”, “1.1.1”) and unnumbered
  front/back-matter headings
- Appendices (with an "EKLER" cover page) and Curriculum Vitae
- NUM (numeric/IEEE) and APA citation styles — see `main.typ` and `main-apa.typ`
- Turkish and English language support (`lang: "tr"` / `lang: "en"`)

## Usage

The main parameters of the `#show: thesis.with(...)` call:

| Parameter | Description |
| --- | --- |
| `name`, `surname`, `student-id` | Student name, surname, and ID |
| `title-tr`, `title-en` | Turkish/English title (up to 3 lines, as an array; printed exactly as written) |
| `approval-title` | Title inside the approval-page sentence, in title case (default: title lines joined) |
| `department-tr/-en`, `program-tr/-en` | Academic department / program |
| `institute` | `"graduate"`, `"informatics"`, `"science"`, `"social-sciences"`, `"energy"`, `"eurasia"` |
| `advisor-tr/-en`, `advisor-univ-tr/-en` | Advisor name and university (TR & EN) |
| `co-advisor-*` | Co-advisor fields, same pattern as `advisor-*` (optional) |
| `jury` | Array of `(name: "...", univ: "...")` dictionaries |
| `cover-date-tr/-en` | Month and year on the covers (e.g. "Mayıs 2025") |
| `defense-date-tr/-en` | Defense date on the approval page |
| `lang` | `"tr"` or `"en"` |
| `degree` | `"masters"` or `"phd"` |
| `degree-name-en` | Degree on the English inner cover (default `auto`: Master of Science / Doctor of Philosophy) |
| `binding` | `"hardcover"` (cloth/bez) or `"softcover"` (cardboard/karton); same covers since v2 |
| `printing` | `"two-sided"` (default) or `"one-sided"`; the backs of the covers, approval, integrity and dedication pages are blank in both |
| `logo` | Cover logo: `image("itulogo.png")` (see below), `auto` (visible placeholder, default) or `none` |
| `dedication`, `foreword`, `abbreviations`, `symbols`, `abstract-tr`, `abstract-en`, `appendices`, `cv` | Front/back-matter content |
| `list-of-figures`, `list-of-tables` | Produce the lists? (default `true`) |
| `bibliography` | `bibliography("refs.bib", style: "ieee", title: "KAYNAKLAR")` |

Helpers for the content files: `abbreviation(term, description)` and
`symbol-entry(term, description)` for the abbreviation/symbol lists, and
`cv-heading`, `cv-education`, `cv-publication` for the CV.

### Cover logo

The official covers show the İTÜ logo (30 × 40 mm). The logo is a registered
trademark of Istanbul Technical University and is **not** included in this
package or covered by its license. Take `fig/itulogo.png` from the official
thesis template distributed by the İTÜ Graduate School, put it in your project
folder and pass `logo: image("itulogo.png")`. Until you do, the covers show a
dashed placeholder so a missing logo cannot go unnoticed; `logo: none` leaves
the slot empty.

### Input checks

The template stops with a clear error message instead of silently producing a
wrong thesis, e.g. for an unknown `degree`/`institute`/`lang`/`printing` value,
a title longer than 3 lines, a misspelled jury key (`university` instead of
`univ`), or a file name passed instead of `include "file.typ"`. Common
alternative spellings are accepted, including the LaTeX class option names
(`"doktora"`, `"bez"`, `"karton"`, `"tekyonlu"`, `"fenbilimleri"`, …), a
single-string title, and jury entries written as `("Name", "University")`.

Body chapters (`= Giriş`, `== Alt başlık`, …) are written as ordinary Typst
headings after the `#show` call; they are numbered automatically.

### Citations and bibliography

Add BibTeX records to `refs.bib` and cite them in the text with `@key`. Choose
the style via the `bibliography` parameter: `style: "ieee"` (numeric) or
`style: "apa"`.

## Changes in 0.3.0 (official template v2.0.0)

- New covers: university name, logo slot, title, author/advisor block, thesis type
  and institute block at the official positions; no automatic uppercasing of titles.
- New approval page text (submission date removed) and the new academic integrity
  declaration page.
- "SUMMARY" → "ABSTRACT", "FOREWORD" → "PREFACE"; the preface ends with the author's name.
- Word-equivalent spacing: 13.8 pt single / 20.7 pt 1.5 line spacing, 12 pt between
  paragraphs, new heading gaps; body text may now be hyphenated when needed.
- Captions above figures and tables, bold label + italic text; figures/tables are
  numbered per chapter (1.1, A.1, …).
- Appendices: the first appendix follows "EKLER" on the same page; appendix titles
  are listed in the table of contents like sections.
- `submission-date-*` is no longer printed (kept for compatibility).

## Notes

- The template targets the `Times New Roman` font; if it is not installed, it
  falls back to alternatives such as `TeX Gyre Termes` / `Libertinus Serif`.
  Installing Times New Roman is recommended for a faithful look.
- Typst does not support EPS; add figures as PNG/PDF/SVG.

## License

MIT — see [LICENSE](LICENSE).

Adapted from the official LaTeX thesis class prepared by the ITU Informatics
Institute.
