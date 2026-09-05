#import "@preview/measured-jair:0.1.0": jair, toprule, midrule, botrule

#show: jair.with(
  title: "A Typst Template for the Journal of Artificial Intelligence Research",
  short-title: "A Typst Template for JAIR",
  short-authors: "Lovelace & Turing",
  authors: (
    (
      name: "Ada Lovelace",
      affiliation: "Analytical Engine Institute, United Kingdom",
      contact-affiliation: "Analytical Engine Institute, London, United Kingdom",
      email: "ada@example.org",
      orcid: "0000-0000-0000-0001",
      corresponding: true,
    ),
    (
      name: "Alan Turing",
      affiliation: "National Physical Laboratory, United Kingdom",
      contact-affiliation: "National Physical Laboratory, Teddington, United Kingdom",
      email: "turing@example.org",
      orcid: "0000-0000-0000-0002",
    ),
  ),
  abstract: [
    This example exercises the template: the title block, the JAIR metadata
    blocks, author-year citations, a numbered equation, a table and a figure,
    a run-in third-level heading, a footnote, an appendix, and the first-page
    contact and license notices. Replace it with your own abstract.
  ],
  track: "Insert JAIR Track Name Here",
  associate-editor: "Insert JAIR AE Name",
  volume: "83",
  article: "1",
  pubdate: "August 2025",
  year: "2025",
  doi: "10.1613/jair.1.xxxxx",
  review: true,
  received: "Received 20 February 2007; accepted 5 June 2009",
  bibliography: bibliography("refs.bib", title: [References], style: "american-psychological-association"),
  appendix: [
    = Supplementary material

    Content passed as `appendix:` is set after the reference list and its
    headings are lettered.
  ],
)

= Introduction

This document shows the Typst port of the JAIR article style. The layout
follows `jair.cls`, which extends ACM's `acmart` in its `acmlarge`
configuration: US Letter, a single column of 10pt Linux Libertine, sans-serif
headings, and a running foot naming the journal, volume and article.#footnote[
  Body footnotes are numbered from 1; the first-page notices do not count.
]

== A subsection

Cite sources in the author-year style JAIR uses @knuth1984texbook. Equations
are numbered on the right:

$ sum_(i=1)^n i = (n (n+1)) / 2 $

=== A third-level heading

Levels 3 and 4 use acmart's run-in faces with a trailing period. Tables take
their captions above and figures below, as in `acmart`.

#figure(
  table(
    columns: 3,
    toprule,
    table.header([*Solver*], [*Solved*], [*Mean time*]),
    midrule,
    [SATzilla], [1,204], [12.4 s],
    [Baseline], [987], [31.8 s],
    botrule,
  ),
  caption: [A table, captioned above the content, with booktabs rules.],
)

#figure(
  rect(width: 60%, height: 48pt, fill: luma(235), stroke: 0.5pt)[
    #set align(center + horizon)
    Your figure here
  ],
  caption: [A figure, captioned below the content.],
)

= Conclusion

Replace this file's contents with your article.
