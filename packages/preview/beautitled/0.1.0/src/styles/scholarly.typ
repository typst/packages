// Style: Scholarly
// ============================================================================
// Elegant traditional style with centered chapters and thin rules
// PRINT-FRIENDLY: thin rules, classic typography
// ============================================================================

#let style-scholarly = (
  chapter: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #align(center)[
        #line(length: 30%, stroke: 0.5pt + secondary)
        #v(0.6em)
        #if show-num [
          #text(size: 10pt, fill: secondary, tracking: 0.15em)[#upper(cfg.chapter-prefix) #numbering("I", num)]
          #v(0.4em)
        ]
        #text(size: cfg.chapter-size, weight: "bold", fill: primary)[#title]
        #v(0.6em)
        #line(length: 30%, stroke: 0.5pt + secondary)
      ]
    ]
  },

  section: (title, ch-num, sec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #text(size: cfg.section-size, weight: "bold", fill: primary)[
        #if show-num [#sec-num.#h(0.6em)]
        #title
      ]
      #v(-0.15em)
      #line(length: 100%, stroke: 0.4pt + secondary)
    ]
  },

  subsection: (title, ch-num, sec-num, subsec-num, cfg, show-num) => {
    let primary = cfg.primary-color

    text(size: cfg.subsection-size, weight: "semibold", fill: primary)[
      #if show-num [#sec-num.#subsec-num#h(0.5em)]
      #title
    ]
  },

  subsubsection: (title, sec-num, subsec-num, subsubsec-num, cfg, show-num) => {
    let primary = cfg.primary-color

    text(size: cfg.subsubsection-size, weight: "medium", style: "italic", fill: primary)[
      #if show-num [#sec-num.#subsec-num.#subsubsec-num#h(0.4em)]
      #title
    ]
  },
)
