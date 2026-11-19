// ---- theme
#import "@preview/aatts:0.1.0": constants, article

#show: article.theme.style.with(header: [Short Article Title · Author Name])
#set document(
  title: "Article Title",
  author: "Author Name",
  date: auto,
)


// cells side by side
#let split(columns: (1fr, 1fr), gutter: article.units.space.md, align: left + top, ..cells) = grid(
  columns: columns,
  column-gutter: gutter,
  align: align,
  ..cells
)


// ============================================================
// Header
// ============================================================

#let hero = (
  title: [An Article Title That May Span Two Lines],
  subtitle: [A short subtitle that frames the article and its central question],
  meta-top: [Preprint · Under Review · #datetime.today().display("[month repr:long] [year]")],
  authors: [
    #text(weight: "semibold")[Author Name#super[1], Co-Author Name#super[1,2]] \
    #text(size: article.units.font.sm, fill: constants.palette.grey.medium)[
      #super[1]Affiliation, City #h(article.units.space.sm)
      #super[2]Second Affiliation, City #h(article.units.space.sm)
      author\@affiliation.org
    ]
  ],
  abstract: [
    A short abstract that states the question, the data, the method, and the main finding in a few sentences. #lorem(112)
  ],
)


// ============================================================
// Body
// ============================================================

#let body = [

  = Introduction

  *Setting the scene.* A paragraph describing the question and why it matters @schwager-etal-2026-unsampled. #lorem(56) @plank-2022-problem.

  #lorem(48) @adilazuarda-etal-2024-towards.#footnote[A footnote with additional detail that would break the reading flow.] #lorem(32)

  #article.widgets.card(title: [Research Question], highlight: constants.palette.blue)[
    One or two questions this article answers, phrased so the reader can check them at the end.
  ]

  = Related Work

  #lorem(72) @munker-2025-fingerprinting.

  == A Subsection

  #lorem(48)

  === A Run-In Paragraph

  #lorem(40)

  = Method

  *Fingerprint.* Describe the material and the procedure. Equations are numbered and can be referenced, see @eq-sim. #lorem(32)

  $ "sim"(arrow(bold(c))_1, arrow(bold(c))_2) = (sum_(k=1)^l c_(1,k) c_(2,k)) / (
    sqrt(sum_(k=1)^l c_(1,k)^2) sqrt(sum_(k=1)^l c_(2,k)^2)
  ) $ <eq-sim>

  #lorem(52)

  #figure(
    image("assets/image-graph_ega.pdf"),
    caption: [The EGA plot of human answers to the HSQ @munker-2025-fingerprinting.],
  ) <fig-ega>

  = Results

  @fig-ega shows the structure of the human answers, @tab-results the reliability scores across conditions. #lorem(48)

  #figure(
    table(
      columns: 5,
      align: (left, right, right, right, right),
      table.header[Condition][Aff.][See.][Agg.][Sed.],
      [Random],       [0.089],   [0.134],   [0.083],   [0.065],
      [Human Full],   [*0.841*], [*0.820*], [*0.790*], [*0.815*],
      [Mistral 7B],   [0.460],   [0.513],   [0.514],   [0.617],
      [Qwen2.5 7B],   [0.492],   [0.535],   [0.551],   [0.298],
    ),
    caption: [Cronbach's Alpha per humor style. The highest score per column is set in *bold*.],
  ) <tab-results>

  
  *Alignment.* #lorem(36)

  *Agreement.* Share of items on which annotators agree, per group. #lorem(48)

  = Discussion

  #lorem(64)

  #lorem(42)

  = Conclusion

  #lorem(86) @plum-etal-2026-ltzglue.

  #bibliography("assets/references.bib", title: [References], style: "apa")
]

#article.layouts.base(..hero, body)
