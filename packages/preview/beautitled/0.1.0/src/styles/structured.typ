// Style: Structured
// ============================================================================
// Clear structured style with boxed chapter numbers
// PRINT-FRIENDLY: boxed chapter numbers, simple lines
// ============================================================================

#let style-structured = (
  chapter: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #grid(
        columns: (auto, 1fr),
        gutter: 0.8em,
        align: horizon,
        [
          #if show-num [
            #box(stroke: 1.5pt + accent, inset: 0.5em)[
              #text(size: 20pt, weight: "bold", fill: accent)[#num]
            ]
          ]
        ],
        [
          #text(size: cfg.chapter-size, weight: "bold", fill: primary)[#title]
        ],
      )
      #v(0.3em)
      #line(length: 100%, stroke: 0.8pt + primary)
    ]
  },

  section: (title, ch-num, sec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #grid(
        columns: (auto, 1fr),
        gutter: 0.6em,
        align: horizon,
        [
          #if show-num [
            #box(stroke: 1.2pt + accent, inset: 0.4em)[
              #text(size: 14pt, weight: "bold", fill: accent)[#sec-num]
            ]
          ]
        ],
        [
          #text(size: cfg.section-size, weight: "bold", fill: primary)[#title]
        ],
      )
    ]
  },

  subsection: (title, ch-num, sec-num, subsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    text(size: cfg.subsection-size, weight: "bold", fill: primary)[
      #if show-num [#text(fill: secondary)[#sec-num.#subsec-num]#h(0.5em)]
      #title
    ]
  },

  subsubsection: (title, sec-num, subsec-num, subsubsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    text(size: cfg.subsubsection-size, weight: "semibold", fill: primary)[
      #if show-num [#text(fill: secondary)[#sec-num.#subsec-num.#subsubsec-num]#h(0.4em)]
      #title
    ]
  },
)
