// Sample document exercising every l10n label ireport currently
// supports: abstract, contents, chapter, section, table, figure,
// appendix, references. See samples/article-en.typ for the flat,
// no-chapters sibling template (iarticle).
//
// Before this will compile, register the local checkout as
// @preview/iarticle:0.1.1 by running ../install_for_test.sh once.
#import "@preview/iarticle:0.1.1": ireport, appendix

#show: ireport.with(
  lang: "en",
  title: "TODO: Report Title",
  authors: ("TODO: Author Name",),
  abstract: [
    TODO: one paragraph summarizing the report.
  ],
)

= TODO: Introduction

TODO: opening chapter text.

== TODO: Background

TODO: subsection text.

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

= TODO: Second Chapter

TODO: as in Knuth's classic essay on literate programming @knuth1984,
this section could reference supporting material. See also
@tufte2001 for an unrelated example of a second citation.

#appendix[
  = TODO: Appendix Title

  TODO: supplementary material. Note the label switches from
  "Chapter" to "Appendix" and numbering switches to letters
  automatically once content is wrapped in `appendix(..)`.
]

#bibliography("refs.bib")
