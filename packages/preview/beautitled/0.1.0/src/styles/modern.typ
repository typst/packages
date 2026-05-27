// Style: Modern
// ============================================================================
// Clean contemporary style with accent line
// PRINT-FRIENDLY: small accent bar only
// ============================================================================

#let style-modern = (
  chapter: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #if show-num [
        #text(size: 12pt, fill: accent, weight: "bold")[#numbering("01", num)]
        #h(0.5em)
        #box(width: 2pt, height: 1.2em, fill: accent)
        #h(0.5em)
      ]
      #text(size: cfg.chapter-size + 4pt, weight: "bold", fill: primary)[#title]
      #v(0.2em)
      #box(width: 40pt, height: 2pt, fill: accent)
    ]
  },

  section: (title, ch-num, sec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #box(width: 4pt, height: 4pt, fill: accent)
      #h(0.5em)
      #text(size: cfg.section-size, weight: "bold", fill: primary)[
        #if show-num [#text(fill: accent)[#sec-num] #h(0.3em)]
        #title
      ]
    ]
  },

  subsection: (title, ch-num, sec-num, subsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color
    text(size: cfg.subsection-size, weight: "semibold", fill: primary)[
      #if show-num [#text(fill: accent)[#sec-num.#subsec-num]#h(0.4em)]
      #title
    ]
  },

  subsubsection: (title, sec-num, subsec-num, subsubsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color
    text(size: cfg.subsubsection-size, weight: "medium", fill: primary)[
      #if show-num [#text(fill: secondary)[#sec-num.#subsec-num.#subsubsec-num]#h(0.3em)]
      #title
    ]
  },
)
