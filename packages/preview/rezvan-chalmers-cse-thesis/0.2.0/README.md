# rezvan-chalmers-cse-thesis
Unofficial Typst package for master's theses at Chalmers University of
Technology and University of Gothenburg CSE.

This package is based on the Chalmers/GU CSE master's thesis layout and is not
an official Chalmers or University of Gothenburg package.

## Features
- Thesis prelude pages (cover, title page, abstract, acknowledgements, TOC).
- Chalmers/GU-style cover and title pages for CSE theses.
- Imprint page fields for supervisor, advisor, examiner, cover caption, and printer.
- Optional imprint-page series metadata for CSE/ODR identifiers such as `CSE 25-122`.
- Running headers/footers with one-sided and two-sided behavior.
- Appendix mode helper (`appendices`) with appendix-style numbering.

## Install / Init
```sh
typst init @preview/rezvan-chalmers-cse-thesis:0.2.0
```

## Usage
```typst
#import "@preview/rezvan-chalmers-cse-thesis:0.2.0": template, appendices, illustrated-cover-background

#let department = "Department of Computer Science and Engineering"
#let cover-background = illustrated-cover-background(
  image("cover.svg", width: 45%),
)

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
  series: none,
  cover-background: cover-background,
  cover-caption: [Caption for the cover illustration, if used.],
  printed-by: none,
)

= Introduction

Your content.

#show: appendices
= Appendix
```

## CSE / Chalmers Notes
- The report is expected to be written in English for master's theses.
- The abstract should be concise and 250-350 words.
- Use at most 10 keywords at the end of the abstract page.
- Produce an A4, ODR-ready PDF with Roman front-matter numbering and Arabic
  numbering starting at the first chapter.
- CSE theses normally use the combined Chalmers University of Technology and
  University of Gothenburg identity.

## Repository Structure
- `src/lib.typ`: package entrypoint and public API.
- `src/pages/`: prelude page components.
- `src/img/`: default logos.
- `examples/`: standalone local examples.
- `template/`: `typst init` scaffold.

## Credits
All credits for the original template go to [CMDJojo's mastery-chs repository](https://github.com/CMDJojo/mastery-chs) (and all forks) for the initial design and layout, which this package is based on.

## License
MIT. See `LICENSE` for details.

The included Chalmers and University of Gothenburg SVG logo assets are derived
from the current Chalmers/GU Word cover templates. Their use is subject to the
universities' own visual identity and logo rules.
