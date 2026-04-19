// Style: Minimal
// ============================================================================
// Ultra-clean with maximum clarity
// PRINT-FRIENDLY: minimal ink usage
// ============================================================================

#let style-minimal = (
  chapter: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #align(center)[
        #if show-num [
          #text(size: 10pt, fill: secondary, tracking: 0.2em)[#numbering("01", num)]
          #v(0.5em)
        ]
        #text(size: cfg.chapter-size, weight: "light", fill: primary)[#title]
      ]
    ]
  },

  section: (title, ch-num, sec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #text(size: cfg.section-size, weight: "regular", fill: primary)[
        #if show-num [#text(fill: secondary)[#sec-num]#h(0.8em)]
        #title
      ]
      #v(0.1em)
      #line(length: 2.5em, stroke: 0.5pt + secondary)
    ]
  },

  subsection: (title, ch-num, sec-num, subsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color
    text(size: cfg.subsection-size, fill: primary)[
      #if show-num [#text(fill: secondary)[#sec-num.#subsec-num]#h(0.6em)]
      #title
    ]
  },

  subsubsection: (title, sec-num, subsec-num, subsubsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color
    text(size: cfg.subsubsection-size, fill: secondary)[
      #if show-num [#sec-num.#subsec-num.#subsubsec-num#h(0.5em)]
      #text(fill: primary)[#title]
    ]
  },
)
