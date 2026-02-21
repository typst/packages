// Style: Classic
// ============================================================================
// Traditional academic style with simple underlines
// PRINT-FRIENDLY: thin lines only
// ============================================================================

#let style-classic = (
  chapter: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #align(center)[
        #if show-num [
          #text(size: 11pt, fill: secondary, tracking: 0.15em)[#upper(cfg.chapter-prefix) #numbering("I", num)]
          #v(0.3em)
        ]
        #text(size: cfg.chapter-size, weight: "bold", fill: primary)[#title]
        #v(0.2em)
        #line(length: 40%, stroke: 0.5pt + secondary)
      ]
    ]
  },

  section: (title, ch-num, sec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #text(size: cfg.section-size, weight: "bold", fill: primary)[
        #if show-num [#sec-num.#h(0.5em)]
        #title
      ]
      #v(-0.2em)
      #line(length: 100%, stroke: 0.6pt + secondary)
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
