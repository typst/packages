// Example acmsmall (ACM journal) paper using the faithful-acmart template.
//
// The wildcard import brings in `acmart`, the theorem environments, the citation
// helpers (cite-text/cite-year/cite-author), and the `cite`/`bibliography` shadows
// that route through the active `bib-backend`.
#import "@preview/faithful-acmart:0.1.0": *

#show: acmart.with(
  format: "acmsmall",
  title: "The Name of the Title Is Hope",

  // Publication metadata
  journal: "JACM",
  acm-volume: 37,
  acm-number: 4,
  acm-article: 111,
  acm-year: 2018,
  acm-month: 8,
  doi: "XXXXXXX.XXXXXXX",
  copyright: "acmlicensed",
  copyright-year: 2018,

  // Authors (consecutive authors sharing an affiliation are grouped on one line)
  authors: (
    (
      name: "Ben Trovato",
      note: [Both authors contributed equally to this research.],
      email: "trovato@corporation.com",
      orcid: "1234-5678-9012",
      affiliation: (institution: "Institute for Clarity in Documentation",
                    city: "Dublin", state: "Ohio", country: "USA"),
    ),
    (
      name: "G.K.M. Tobin",
      note: [Both authors contributed equally to this research.],
      corresponding: true,
      email: "webmaster@marysville-ohio.com",
      affiliation: (institution: "Institute for Clarity in Documentation",
                    city: "Dublin", state: "Ohio", country: "USA"),
    ),
    (
      name: "Lars Thørväld",
      email: "larst@affiliation.org",
      affiliation: (institution: "The Thørväld Group",
                    city: "Hekla", country: "Iceland"),
    ),
  ),

  abstract: [
    A clear and well-documented Typst document is presented as an article
    formatted for publication by ACM. Based on the acmart class, this template
    reproduces the look of the LaTeX original — fonts, sizes, and spacing — while
    letting you write idiomatic Typst.
  ],

  // CCS concepts: (significance, area, concept). >=500 bold, >=300 italic, else roman.
  ccs: (
    (500, "Computing methodologies", "Massively parallel algorithms"),
    (300, "Computing methodologies", "Concurrent algorithms"),
  ),

  keywords: ("typesetting", "ACM", "Typst", "templates"),
)

= Introduction
ACM's consolidated article template provides a consistent style across ACM
publications. This Typst port lets you write a normal Typst document and have it
render like acmart. You use ordinary headings, paragraphs, figures, and
citations @Cohen:1996:EAE @Li:2008:PUC.

A second paragraph is indented, as in the LaTeX original, and the text is set on
the same baseline grid.

== Using the template
Call `acmart.with(...)` in a show rule and write the body as usual. Sections,
subsections, and run-in headings all follow the acmsmall styling.

=== A finer point
Run-in headings continue inline with the following text, just like LaTeX.

= Results

#figure(
  rect(width: 5cm, height: 3cm, fill: luma(230)),
  caption: [A placeholder figure. Captions are sans-serif and use a period
    separator, as ACM journals require.],
)

Theorem-like environments share a counter numbered within the section:

#theorem[
  For every $epsilon > 0$ there exists a $delta > 0$ such that the template
  renders within $delta$ of the LaTeX original.
]

#proof[
  Build both with the same content and compare. The difference is bounded by the
  engines' differing line-breaking, which is below $epsilon$.
]

#definition[
  A _faithful port_ matches fonts, sizes, margins, and spacing of the original.
]

We can also use lists:

- Idiomatic Typst source
- acmart-faithful output

+ Pick a format
+ Write your paper
+ Submit

// A single relative bibliography path works on every backend. (Multiple .bib files on
// the `bibtex`/`biblatex` backends must use project-absolute paths, e.g. "/refs.bib".)
#bibliography("refs.bib")
