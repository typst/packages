# ls3-uni-stuttgart-milestone

Milestone report template of the Department of Stochastic Simulation
and Safety Research for Hydrosystems, LS3, at the Institute for
Modelling Hydraulic and Environmental Systems, University of Stuttgart.
PhD candidates write it for the halftime presentation of their doctoral
project. English or German, two-sided, with title page, optional
abstract, abbreviations and notation, table of contents, and
bibliography.

## Start a report

In the typst.app web app, choose "Start from template" and search for
`ls3-uni-stuttgart-milestone`. On your own machine, run

```bash
typst init @preview/ls3-uni-stuttgart-milestone:0.1.0 my-milestone
```

Then open `main.typ`, fill in your metadata, and write your chapters in
`chapters/`.

## Other departments

The title page names IWS and LS3 by default. Set `institute` and
`chair` to use the template for another department of the university.

```typst
#import "@preview/ls3-uni-stuttgart-milestone:0.1.0": milestone

#show: milestone.with(
  institute: "Institute of Engineering Geodesy",
  chair: "Department of Geodetic Measurement Systems",
  // ...
)
```

## Logos

The University of Stuttgart logo ships with the package and appears on
the title page without any setup. The title page crops the official
logo, drops the "Germany" line of the English version, and sets the
institute and department below it from `institute` and `chair`.
The University of Stuttgart permitted bundling its logo with this
template. The logo is covered by neither package license, see `LICENSE`.

Pass `university-logo: none` to leave it out. A replacement must be one
of the official PDFs from the
[corporate design page](https://www.beschaeftigte.uni-stuttgart.de/uni-services/kommunikation-und-marketing/corporate-design/logo-und-schrift/),
because the crop is measured on them. `additional-logo` takes any
content, for example a project logo, and centers it on the title page.

## Font

The template uses TeX Gyre Heros, a free Helvetica clone. The typst.app
web app has it built in. On your own machine, install it from
[CTAN](https://ctan.org/pkg/tex-gyre-heros).

## Parameters

| Parameter | Default | Meaning |
| --- | --- | --- |
| `title` | `[]` | Research title |
| `cover-title` | `auto` | Title on the title page, may use `\` for line breaks |
| `author` | `""` | Your name |
| `language` | `"english"` | `"english"` or `"german"` |
| `presentation-date` | `none` | Date of the milestone presentation |
| `supervisor` | `""` | Name of the supervisor |
| `co-supervisor` | `none` | Name of the co-supervisor |
| `examiners` | `()` | Array of names |
| `institute`, `chair` | `auto` | Institute and department, IWS and LS3 by default |
| `university-logo` | `auto` | Bundled university logo, an official logo PDF, or `none` |
| `additional-logo` | `none` | Any content, centered on the title page |
| `report-type` | `auto` | Line above the title, "Milestone Report" by default |
| `abstract` | `none` | Abstract content |
| `abbreviations` | `none` | Content, or `auto` for a sorted list from the `abbr` package |
| `notation` | `none` | Notation content |
| `bib` | `none` | A `bibliography(...)` element |
| `body-font` | `"sans"` | `"sans"`, or `"serif"` for a LaTeX-like body |
| `heading-rule` | `false` | `true` draws a thin blue rule below every chapter heading |

## License

The package is MIT licensed, see `LICENSE`. Source, issues, and pull
requests live at
[LS3-university-of-stuttgart/ls3-typst-templates-public](https://github.com/LS3-university-of-stuttgart/ls3-typst-templates-public). The files in `template/`,
which `typst init` copies into your project, are under MIT-0, so your
report carries no license obligations.

## Changelog

### 0.1.0

First release on Typst Universe. The University of Stuttgart logo is
bundled and can be replaced or left out with `university-logo`. The
title page crops the official logo and sets the institute and chair
lines in Typst, so other departments can set their own. Code listings
use codly 2.0.0, so the template needs Typst 0.15.0 or newer.
