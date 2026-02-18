// Style: Classical
// ============================================================================
// Refined scholarly style with small caps and minimal decoration
// PRINT-FRIENDLY: minimal decoration, serif-friendly
// ============================================================================

#let style-classical = (
  chapter: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #align(center)[
        #if show-num [
          #text(size: 12pt, fill: secondary)[#cfg.chapter-prefix #num]
          #v(0.5em)
        ]
        #text(size: cfg.chapter-size, weight: "bold", fill: primary, tracking: 0.03em)[#smallcaps[#title]]
      ]
    ]
  },

  section: (title, ch-num, sec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    text(size: cfg.section-size, weight: "bold", fill: primary)[
      #if show-num [#text(fill: secondary)[§#sec-num.]#h(0.5em)]
      #title
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

    text(size: cfg.subsubsection-size, style: "italic", fill: primary)[
      #if show-num [#sec-num.#subsec-num.#subsubsec-num#h(0.4em)]
      #title
    ]
  },
)
