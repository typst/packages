// Style: Notes
// ============================================================================
// Optimized for course notes and study materials
// PRINT-FRIENDLY: very light, easy to annotate
// ============================================================================

#let style-notes = (
  chapter: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #if show-num [
        #text(size: 10pt, fill: secondary)[#cfg.chapter-prefix #num]
        #h(0.3em)
        #text(fill: secondary)[|]
        #h(0.3em)
      ]
      #text(size: cfg.chapter-size, weight: "bold", fill: primary)[#title]
    ]
  },

  section: (title, ch-num, sec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #text(size: cfg.section-size, weight: "bold", fill: primary)[
        #if show-num [#text(fill: secondary)[#sec-num.]#h(0.4em)]
        #title
      ]
      #v(-0.2em)
      #line(length: 4em, stroke: 0.5pt + secondary)
    ]
  },

  subsection: (title, ch-num, sec-num, subsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    text(size: cfg.subsection-size, weight: "semibold", fill: primary)[
      #if show-num [#text(fill: secondary)[#sec-num.#subsec-num]#h(0.4em)]
      #title
    ]
  },

  subsubsection: (title, sec-num, subsec-num, subsubsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    text(size: cfg.subsubsection-size, fill: primary)[
      #text(fill: secondary)[•]#h(0.3em)
      #if show-num [#text(fill: secondary)[#sec-num.#subsec-num.#subsubsec-num]#h(0.3em)]
      #title
    ]
  },
)
