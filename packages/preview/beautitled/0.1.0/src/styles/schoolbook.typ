// Style: Schoolbook
// ============================================================================
// Textbook style optimized for course materials and lessons
// PRINT-FRIENDLY: simple lines, clear hierarchy
// ============================================================================

#let style-schoolbook = (
  chapter: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color

    block(width: 100%, above: 0pt, below: 0pt, stroke: (bottom: 1.5pt + accent), inset: (bottom: 0.5em))[
      #if show-num [
        #text(size: 12pt, fill: accent, weight: "bold")[#cfg.chapter-prefix #num]
        #h(0.5em)
        #text(size: 12pt, fill: accent)[—]
        #h(0.5em)
      ]
      #text(size: cfg.chapter-size + 2pt, weight: "bold", fill: primary)[#title]
    ]
  },

  section: (title, ch-num, sec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #grid(
        columns: (auto, 1fr),
        gutter: 0.5em,
        align: horizon,
        [
          #if show-num [
            #text(size: cfg.section-size, weight: "bold", fill: accent)[#sec-num.]
          ]
        ],
        [
          #text(size: cfg.section-size, weight: "bold", fill: primary)[#title]
        ],
      )
      #line(length: 100%, stroke: 0.5pt + primary.lighten(50%))
    ]
  },

  subsection: (title, ch-num, sec-num, subsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color

    text(size: cfg.subsection-size, weight: "semibold", fill: primary)[
      #if show-num [#text(fill: accent)[#sec-num.#subsec-num]#h(0.5em)]
      #title
    ]
  },

  subsubsection: (title, sec-num, subsec-num, subsubsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    text(size: cfg.subsubsection-size, weight: "medium", fill: primary)[
      #if show-num [#text(fill: secondary)[#sec-num.#subsec-num.#subsubsec-num]#h(0.4em)]
      #title
    ]
  },
)
