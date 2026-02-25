# liu-thesis

A [Typst](https://typst.app/) template for theses at Linköping University, Sweden.

Reproduces the official [liuthesis](https://gitlab.liu.se/olale55/liuthesis) LaTeX template in Typst — same layout, same typography, same structure, without the LaTeX.

> **Status:** Student thesis template is published as v0.1.0 on the Typst package registry. Graduate thesis (doctoral/licentiate) is work in progress.

## Quick start

```bash
typst init @preview/liu-thesis:0.1.0 my-thesis
```

Then edit `my-thesis/main.typ`:

```typst
#import "@preview/liu-thesis:0.1.0": student-thesis

#show: student-thesis.with(
  title: (
    swedish: "En titel på svenska",
    english: "A Title in English",
  ),
  subtitle: (
    swedish: none,
    english: "With a Subtitle",
  ),
  author: "Your Name",
  examiner: "Examiner Name",
  supervisor: "Supervisor Name",
  subject: "Computer Science",
  department: (
    swedish: "Institutionen för datavetenskap",
    english: "Department of Computer and Information Science",
  ),
  department-short: "IDA",
  publication-year: "2026",
  thesis-number: "001",
  language: "swedish",
  level: "msc",
  faculty: "lith",
  abstract: [Your abstract here.],
  acknowledgments: [Your acknowledgments here.],
  bibliography: bibliography("references.bib", title: none),
)

= Introduction
Your thesis starts here.
```

## Parameters

### `student-thesis`

| Parameter | Type | Description |
|-----------|------|-------------|
| `title` | `(swedish: str, english: str)` | Thesis title in both languages |
| `subtitle` | `(swedish: str?, english: str?)` | Optional subtitle in both languages |
| `author` | `str` | Author name |
| `examiner` | `str` | Examiner name |
| `supervisor` | `str` | Supervisor name |
| `external-supervisor` | `str?` | Optional external supervisor name |
| `subject` | `str` | Thesis subject area |
| `department` | `(swedish: str, english: str)` | Department name |
| `department-short` | `str` | Department abbreviation (e.g. `"IDA"`) |
| `publication-year` | `str` | Year of publication |
| `thesis-number` | `str` | Thesis serial number |
| `language` | `str` | `"swedish"` or `"english"` |
| `level` | `str` | `"msc"` or `"bachelor"` |
| `faculty` | `str` | `"lith"`, `"filfak"`, or `"hu"` |
| `abstract` | `content?` | Abstract content |
| `acknowledgments` | `content?` | Acknowledgments content |
| `bibliography` | `content?` | Bibliography (pass a `bibliography()` call) |

### `graduate-thesis` (WIP)

Parameters for doctoral/licentiate theses are being finalized. See `lib.typ` for the current signature.

## Requirements

- Typst 0.14.0 or later
- Georgia font (for the title page; falls back to New Computer Modern)
- New Computer Modern Sans (optional; title page header — falls back to serif)

## License

MIT — see [LICENSE](LICENSE) and [`typst.toml`](typst.toml).

Typst reimplementation that reproduces the layout of the [liuthesis](https://gitlab.liu.se/olale55/liuthesis) LaTeX template by Ola Leifler, with contributions from Jonathan Jogenfors, Ivan Ukhov, and Jan-Åke Larsson.

## Disclaimer

This project is **not** officially affiliated with, endorsed by, or maintained by Linköping University (LiU).

The logo files in `assets/figures/` are the property of Linköping University and are **not** covered by the MIT license. They are included here for convenience in typesetting theses. For official usage guidelines, see LiU's [logotype download page](https://liu.se/en/organisation/liu/uf/kom/download-logotype) and brand policy.

---

## Roadmap

### 0.1.0 — Student thesis (`student-thesis`)

- MSc and Bachelor support (`level: "msc"` / `"bachelor"`)
- Swedish and English (`language`)
- Title page, copyright page, abstract, acknowledgments, TOC
- VZ43 chapter headings, running headers, page numbering
- Parameter validation with clear error messages
- Dedication page (optional centered italic text)
- List of Figures / List of Tables (conditional)
- Final visual verification pass with `diff-pdf`
- Publish to the Typst package registry

### 0.2.0 — Doctoral/Licentiate thesis (`graduate-thesis`)

- S5 page format (165×240mm) with asymmetric margins
- Graduate title page (publication series, division, ISSN)
- Permission page (replaces copyright page)
- Faculty-specific formatting: LiTH, FilFak
- Dual abstracts (Swedish + English)
- ISBN metadata and Creative Commons licensing (`ccby`, `ccbync`)
- Subseries support (FilFak)
- Print-friendly mode (chapters forced to recto pages)

### 0.3.0 — Exhibit page and extras

- Exhibit page / spikblad (`exhibit-page`) for PhD/Lic defenses
- Faculty-specific exhibit styles (LiTH vs FilFak)
- Article/publication inclusion system for compilation theses

## Project structure

```text
├── lib.typ                      # Public API — exports student-thesis(), graduate-thesis()
├── src/
│   ├── strings.typ              # Swedish/English string tables
│   ├── page-setup.typ           # Shared page dimensions, margins, fonts
│   ├── chapter-heading.typ      # VZ43 chapter heading style (shared)
│   ├── formats.typ              # Page format dictionaries (student, S5)
│   ├── faculty.typ              # Faculty-specific data (series, ISSN)
│   ├── title-page.typ           # Student title page layout
│   ├── graduate-title-page.typ  # Graduate title page layout
│   ├── copyright-page.typ       # Copyright/Upphovsrätt page (student)
│   ├── permission-page.typ      # Permission page (graduate)
│   └── frontmatter.typ          # Abstract, acknowledgments, TOC (shared)
├── assets/
│   └── figures/                 # LiU logos (Swedish and English)
├── template/
│   ├── main.typ                 # Default template for typst init
│   └── references.bib           # Example bibliography
├── tests/
│   ├── demo-graduate.typ        # Graduate thesis demo (LiTH lic)
│   ├── demo-lith-phd.typ        # LiTH PhD demo
│   ├── demo-filfak-lic.typ      # FilFak licentiate demo
│   ├── demo-filfak-phd.typ      # FilFak PhD demo
│   └── references.bib           # Shared bibliography for tests
├── typst.toml                   # Package manifest
└── thumbnail.png                # Package registry thumbnail
```

## Contributing

Contributions are welcome — especially around visual accuracy, faculty support, and PhD/Lic templates.

To verify changes against the LaTeX reference, obtain the original [liuthesis](https://gitlab.liu.se/olale55/liuthesis) demo PDF and run:

```bash
typst compile --root . template/main.typ output/main.pdf
diff-pdf --output-diff=output/diff.pdf /path/to/demo_student_thesis.pdf output/main.pdf
```
