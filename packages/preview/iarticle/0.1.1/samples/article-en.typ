// Sample document for iarticle, the flat sibling of ireport: no
// chapters, sections start at the top level, no forced page breaks, no
// auto table of contents by default (all overridable - see README).
// See samples/report-en.typ for the chapter-based sibling.
//
// Before this will compile, register the local checkout as
// @preview/iarticle:0.1.1 by running ../install_for_test.sh once.
#import "@preview/iarticle:0.1.1": iarticle, appendix

#show: iarticle.with(
  lang: "en",
  title: "TODO: Paper Title",
  authors: ("TODO: Author Name",),
  abstract: [
    TODO: one paragraph summarizing the paper.
  ],
)

= TODO: Introduction

TODO: opening section text.

== TODO: Related Work

TODO: subsection text, e.g. referencing Knuth's essay on literate
programming @knuth1984. See also @tufte2001 for an unrelated example of
a second citation.

#figure(
  rect(width: 4cm, height: 2.5cm, stroke: 0.5pt),
  caption: [TODO: figure caption],
)

#figure(
  table(
    columns: 3,
    [*Column A*], [*Column B*], [*Column C*],
    [TODO], [TODO], [TODO],
  ),
  caption: [TODO: table caption],
)

= TODO: Method

TODO: main content.

#appendix[
  = TODO: Additional Data

  TODO: supplementary material. `appendix(..)` works the same way here
  as in ireport - it's the "chapter" vs. "section" label that differs
  between the two templates, not the appendix mechanism.
]

#bibliography("refs.bib")
