// typst init @preview/econ-working-paper
// typst compile main.typ

#import "@preview/econ-working-paper:0.3.1": *

#show: paper.with(
  // -- metadata -----------------------------------------------------------
  title: "Your Paper Title",
  subtitle: none,                   // e.g., "WORK IN PROGRESS"
  authors: (
    (
      name: "Author One",
      affiliation: "University A",
      email: "one@a.edu",
      note: "ORCID: 0000-0001-2345-6789",
    ),
    (
      name: "Author Two",
      affiliation: "University B",
    ),
  ),
  date: "2026-01-01",              // date string shown on title page
  abstract: [Your abstract here.],
  keywords: [keyword one, keyword two],
  jel: [G14, G38],                 // optional JEL classification codes
  acknowledgments: [We thank ...], // footnote on the Abstract heading

  // -- bibliography -------------------------------------------------------
  bibliography: bibliography("refs.bib", title: "References"),
  citation-style: "chicago-author-date", // any CSL style name

  // -- typography ---------------------------------------------------------
  font: ("Linux Libertine", "Times New Roman", "New Computer Modern"),
  fontsize: 12pt,                   // body text size

  // -- layout -------------------------------------------------------------
  paper: "us-letter",               // "us-letter" or "a4"
  anonymize: false,                 // suppress authors, affiliations, date, acknowledgments
  draft: false,                     // "DO NOT CITE" watermark
  endfloat: false,                  // move figures/tables to end, leave placeholders inline
  line-spacing: "double",           // "double", "onehalf", or "single"
)

= Introduction
Your text here.
