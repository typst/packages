// ---- plugins
#import "@preview/cades:0.3.1" as cades
#import "@preview/tdtr:0.6.1" as tdtr

// ---- theme
#import "@preview/aatts:0.1.0": constants, poster

#show: poster.theme.style
#set document(
  title: "Poster Title",
  author: "Author Name",
  date: auto,
)


// cells side by side
#let split(columns: (1fr, 1fr), gutter: poster.units.space.md, align: left + top, ..cells) = grid(
  columns: columns,
  column-gutter: gutter,
  align: align,
  ..cells
)

// muted caption below a chart that is not a numbered figure
#let note(body) = text(
  size: poster.units.font.sm,
  fill: constants.palette.grey.medium,
  style: "italic",
  body,
)

// vertical rhythm between blocks of a section
#let gap = v(poster.units.space.md)


// ============================================================
// Header
// ============================================================

#let hero = (
  title: [A Poster Title],
  subtitle: [A short subtitle that frames the poster and its central question],
  meta-top: [
    #text(weight: "semibold")[Author Name, Co-Author Name] \
    Affiliation, Second Affiliation
    #h(1fr)
    #text(weight: "light", fill: constants.palette.grey.medium)[
      Conference Name · Venue, Date · author\@affiliation.org
    ]
  ],
)


// ============================================================
// Body
// ============================================================

#let body = [

  *TL;DR:* _#lorem(52)_

  == Motivation

  *Setting the scene.* A short paragraph describing the question, the data, or the method. Keep it to a few sentences, a poster is read while standing @schwager-etal-2026-unsampled. #lorem(42) @plank-2022-problem.

  #lorem(12) @adilazuarda-etal-2024-towards. #lorem(28)

  == Method

  *Fingerprint.* Describe the material and the procedure. Use `#gap` between blocks to keep the vertical rhythm consistent across columns. #lorem(42)

  #gap

  #figure(
    [
      #let c1 = $arrow(bold(C)_bold(X^1))$
      #let c2 = $arrow(bold(C)_bold(X^2))$
      #let su = $sum_(k=1)^l$

      $ "sim"(c1, c2) = (su c1_k c2_k) / (
        sqrt(su (c1_k)^2) sqrt(su (c2_k)^2)
      ) $
    ],
    caption: [Similarity between two correlation matrices/fingerprints.]
  )

  #gap

  *Taxonomy.* Categories ($C$) are mapped onto a shared hierarchy, written as a nested list. #lorem(48)

  #gap

  #align(center, scale(230%, reflow: true, tdtr.tidy-tree-graph(
    compact: true,
    spacing: (12pt, 24pt),
    node-inset: 4pt,
    draw-node: (
      stroke: poster.units.weight.sm + constants.palette.grey.dark,
      corner-radius: poster.units.weight.lg,
    ),
    draw-edge: (stroke: poster.units.weight.sm + constants.palette.grey.medium),
  )[
    - *Culture*
      - Practice
        - Food
        - Holidays
      - Norms
        - Etiquette
        - Values
      - Knowledge
        - History
        - Geography
  ]))

  #gap

  *Procedure.* Agreement is computed per item over adjacent label pairs. #lorem(32)

  #colbreak()

  *Implementation:* #lorem(72)

  == Results

  #lorem(64)

  #gap

  #figure(
    image("assets/image-graph_ega.pdf"),
    caption: [The EGA plot of human answers to the HSQ @munker-2025-fingerprinting],
  )

  #gap


  Group A reaches only *fair agreement* in both conditions. In contrast, Group B agrees strongly, but almost always gives the same answer. #lorem(48)

  #let group(title) = (
    table.hline(stroke: 0.05em),
    table.cell(colspan: 5, align: center, strong(title)),
    table.hline(stroke: 0.05em),
  )



#figure(
  kind: table,
  placement: auto,
  text(size: 0.8em, table(
    columns: 5,
    align: (left, right, right, right, right),
    stroke: none,
    table.vline(x: 1, stroke: 0.05em),

    table.header[][Aff.][See.][Agg.][Sed.],

    ..group[Baseline Conditions],
    [Random],       [0.089],   [0.134],   [0.083],   [0.065],
    [Human Items],  [0.118],   [0.105],   [0.084],   [0.103],
    [Human Full],   [*0.841*], [*0.820*], [*0.790*], [*0.815*],

    ..group[LLMs w/o context window],
    [Llama3.1 8B],  [0.118],   [0.081],   [0.104],   [0.110],
    [Llama3.3 70B], [0.034],   [0.070],   [0.024],   [0.013],
    [Mistral 7B],   [0.121],   [0.130],   [0.089],   [0.122],
    [Mistral 123B], [*0.184*], [*0.189*], [*0.177*], [*0.206*],
    [Qwen2.5 7B],   [0.095],   [0.061],   [0.116],   [0.096],
    [Qwen2.5 72B],  [0.008],   [0.073],   [0.103],   [0.041],

    ..group[LLMs w/ 5-item context window],
    [Llama3.1 8B],  [0.138],   [0.091],   [0.087],   [0.149],
    [Llama3.3 70B], [0.063],   [0.144],   [0.087],   [0.076],
    [Mistral 7B],   [0.460],   [0.513],   [0.514],   [*0.617*],
    [Mistral 123B], [0.220],   [0.242],   [0.157],   [0.232],
    [Qwen2.5 7B],   [*0.492*], [*0.535*], [*0.551*], [0.298],
    [Qwen2.5 72B],  [0.094],   [0.138],   [0.084],   [0.113],
  )),
  caption: [
    Cronbach's Alpha reliability scores for four humor styles across different experimental conditions. The
    table compares the baseline conditions with both LLM experiments. Values above 0.8 indicate acceptable reliability for applied research The highest score within each group-column  combination is highlighted in *bold*.
  ],
)

  #colbreak()

  == Discussion

  *What it means* @munker-2025-fingerprinting: #lorem(32).

  #lorem(68)

  == Conclusion

  *What it means* @munker-2025-fingerprinting: #lorem(32).

  #lorem(16) @plum-etal-2026-ltzglue. #lorem(24)

  #gap

  #poster.widgets.card(title: [Open Question], highlight: constants.palette.blue)[
    A question phrased for the discussion at the poster? #lorem(12)
  ]

  #gap

  #split(
    columns: (1fr, auto),
    align: (left + horizon, right + horizon),
    [
      #poster.widgets.statement[Let's talk!]
      author\@affiliation.org \
      #note[Scan for the paper, code, and data.]
    ],
    cades.qr-code("https://simon-muenker.github.io/", width: 8cm, color: constants.palette.grey.dark),
  )

  #bibliography("assets/references.bib", style: "apa")
]

#poster.layouts.base(..hero, body)
