# rezvan-chalmers-cse-thesis
Unofficial Typst package for master's theses at Chalmers University of
Technology and University of Gothenburg CSE.

This package is based on the Chalmers/GU CSE master's thesis layout and is not
an official Chalmers or University of Gothenburg package.

## Features
- Thesis prelude pages (cover, title page, abstract, acknowledgements, TOC).
- Chalmers/GU-style cover and title pages for CSE theses.
- Imprint page fields for supervisor, advisor, examiner, cover caption, and printer.
- Running headers/footers with one-sided and two-sided behavior.
- Appendix mode helper (`appendices`) with appendix-style numbering.

## Install / Init
```sh
typst init @preview/rezvan-chalmers-cse-thesis:0.1.0
```

## Usage
```typst
#import "@preview/rezvan-chalmers-cse-thesis:0.1.0": template, appendices

#let department = "Department of Computer Science and Engineering"

#show: template.with(
  title: "Your Thesis Title",
  subtitle: "Optional subtitle",
  authors: ("Your Name",),
  department: department,
  subject: "Computer Science and Engineering",
  supervisor: ("Supervisor Name", department),
  advisor: none,
  examiner: ("Examiner Name", department),
  abstract: [Write your abstract here.],
  acknowledgements: [Write your acknowledgements here.],
  keywords: ("keyword-1", "keyword-2"),
  cover-caption: [Caption for the cover illustration, if used.],
  printed-by: none,
)

= Introduction

Your content.

#show: appendices
= Appendix
```

## Repository Structure
- `src/lib.typ`: package entrypoint and public API.
- `src/pages/`: prelude page components.
- `src/img/`: default logos.
- `examples/`: standalone local examples.
- `template/`: `typst init` scaffold.

## License
MIT. See `LICENSE` for details.

The included Chalmers and University of Gothenburg logo assets are used to
reproduce the thesis layout. Their use is subject to the universities' own
visual identity and logo rules.
