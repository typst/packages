// Style: Creative (Student Portfolio)
// ============================================================================
// Clean modern style for student work and portfolios
// PRINT-FRIENDLY: minimal ink, clear hierarchy
// ============================================================================

#let style-creative = (
  chapter: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #if show-num [
        #text(size: 10pt, fill: accent, weight: "medium")[#cfg.chapter-prefix #num]
        #v(0.2em)
      ]
      #text(size: cfg.chapter-size, weight: "bold", fill: primary)[#title]
      #v(0.3em)
      #grid(
        columns: (auto, auto, auto),
        gutter: 0.3em,
        circle(radius: 2.5pt, stroke: 0.8pt + accent),
        circle(radius: 2.5pt, stroke: 0.8pt + primary),
        circle(radius: 2.5pt, stroke: 0.8pt + cfg.secondary-color),
      )
    ]
  },

  section: (title, ch-num, sec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color

    grid(
      columns: (auto, 1fr),
      gutter: 0.6em,
      align: horizon,
      [
        #if show-num [
          #circle(radius: 10pt, stroke: 1.5pt + accent)[
            #align(center + horizon)[
              #text(size: 10pt, weight: "bold", fill: accent)[#sec-num]
            ]
          ]
        ] else [
          #circle(radius: 3pt, stroke: 1pt + accent)
        ]
      ],
      [
        #text(size: cfg.section-size, weight: "bold", fill: primary)[#title]
        #v(-0.4em)
        #line(length: 3em, stroke: 0.8pt + accent)
      ],
    )
  },

  subsection: (title, ch-num, sec-num, subsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    grid(
      columns: (auto, auto, 1fr),
      gutter: 0.3em,
      align: horizon,
      box(width: 8pt, height: 2pt, stroke: 0.8pt + cfg.accent-color),
      box(width: 4pt, height: 2pt, stroke: 0.8pt + secondary),
      text(size: cfg.subsection-size, weight: "semibold", fill: primary)[
        #if show-num [#text(fill: secondary)[#sec-num.#subsec-num]#h(0.3em)]
        #title
      ],
    )
  },

  subsubsection: (title, sec-num, subsec-num, subsubsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color
    text(size: cfg.subsubsection-size, fill: primary)[
      #text(fill: cfg.accent-color)[→]#h(0.2em)
      #if show-num [#text(fill: secondary)[#sec-num.#subsec-num.#subsubsec-num]#h(0.2em)]
      #text(weight: "medium")[#title]
    ]
  },
)
