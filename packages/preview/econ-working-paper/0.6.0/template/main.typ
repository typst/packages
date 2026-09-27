// typst init @preview/econ-working-paper
// typst compile main.typ

#import "@preview/econ-working-paper:0.6.0": *

#show: paper.with(
  // -- metadata -----------------------------------------------------------
  title: "Your Paper Title",
  status: none,                     // e.g., "WORK IN PROGRESS"; hidden on anonymize
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
  // jel: [G14, G38],               // optional JEL classification codes
  acknowledgments: [We thank ...], // footnote on the Abstract heading
  // epigraph: (                    // optional opening quotation
  //   quote: [Your quote here.],
  //   attribution: [Author, _Source_],
  // ),

  // -- bibliography -------------------------------------------------------
  bibliography: bibliography("refs.bib", title: "References"),
  citation-style: "chicago-author-date", // any CSL style name

  // -- typography ---------------------------------------------------------
  font: ("Linux Libertine", "Times New Roman", "New Computer Modern"),
  fontsize: 12pt,                   // body text size
  table-fontsize: 10pt,             // table body text size
  math-fontsize: 1em,               // inline math size, e.g. 0.9em

  // -- layout -------------------------------------------------------------
  paper: "us-letter",               // "us-letter" or "a4"
  anonymize: false,                 // suppress authors, affiliations, date, acknowledgments
  draft: false,                     // "DO NOT CITE" watermark
  endfloat: false,                  // false, true/"both", "tables", or "figures"
  endfloat-position: "end",         // "end", "after-references", or "after-appendix"
  line-spacing: "double",           // "double", "onehalf", or "single"
)

= Introduction
Your text here.
