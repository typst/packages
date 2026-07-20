// diprint — arXiv-style paper template
//
//   typst compile main.typ              # PDF
//   typst compile --features html main.typ output.html

#import "@preview/diprint:0.1.0": diprint, diprint-appendices

#show: diprint.with(
  title: "Typst Template for arXiv-style Preprints",
  authors: (
    (
      name: "wylited",
      email: "wylited@gmail.com",
      affiliation: "Earth",
    ),
    (
      name: "Author Two",
      email: "author.two@institute.org",
      affiliation: "Institute of Research",
      orcid: "0000-0000-0000-0000"
    ),
  ),
  abstract: [
    A brief abstract summarizing the paper. Keep it to a single
    paragraph covering the motivation, approach, and main findings.
    The template centres the abstract heading and sets the body
    justified with hyphenation off, matching the arXiv convention.
  ],
  keywords: ("keyword one", "keyword two"),
  date: "January 2025",
)

#set cite(style: "chicago-author-date")

= Introduction

This template reproduces the clean single-column layout of arXiv
preprints — double horizontal rules, centred title and author block,
abstract with small-caps heading, and numbered sections. It compiles
to both PDF and HTML from the same source.

The body font is New Computer Modern, set justified with no
hyphenation. Headings are numbered "1.1" style and the first page
carries a centred page number in the footer.

= Related Work

Prior art includes the original @vaswani2017attention transformer
architecture and later work on model compression
@hinton2015distilling. The long short-term memory network
@hochreiter1997long remains a foundational sequence model.

Bringhurst's @bringhurst2004elements is the standard reference for
typographic craft and informs many of the spacing decisions in this
template.

= Methods

The template is a show rule that wraps the document in either PDF
layout commands (page margins, rules, alignments) or semantic HTML
elements depending on the target format. The approach uses Typst's
`std.target` to branch at compile time.

= Results

Tables and figures are numbered automatically.

#figure(
  table(
    align: center,
    columns: (auto, auto, auto),
    stroke: 0.5pt,
    inset: 5pt,
    [Method], [Precision], [F1],
    [Baseline], [0.72], [0.70],
    [Ours], [0.89], [0.90],
  ),
  caption: [Results on the benchmark dataset.]
) <tab:results>

#figure(
  rect(width: 40%, height: 60pt, fill: rgb("e0e0e0")),
  caption: [A placeholder figure.]
) <fig:placeholder>

In @tab:results we report precision and F1 scores. The figure in
@fig:placeholder illustrates the pipeline.

= Discussion

The template handles headings up to four levels. Level-3 and level-4
headings run inline with the text. Equations are numbered as well:

$
  sum_(k=1)^n k = (n(n+1)) / 2
$

Lists work as usual:

- Bullet items
- Another bullet
  - Nested

+ Ordered items
+ Another ordered item

#bibliography(title: [References], "references.bib")

// ---- Appendices ----
#show: diprint-appendices

= Additional Proofs

Appendix sections use letter-based numbering instead of the numeric
scheme used in the main body.

== A Subsection

Appendices support subsections numbered "A.1", "A.2", and so on.
