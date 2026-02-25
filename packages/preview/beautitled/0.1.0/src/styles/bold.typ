// Style: Bold
// ============================================================================
// Strong visual hierarchy with thick left border
// PRINT-FRIENDLY: left border only, no backgrounds
// ============================================================================

#let style-bold = (
  chapter: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color

    block(width: 100%, above: 0pt, below: 0pt, stroke: (left: 4pt + accent), inset: (left: 1em, y: 0.3em))[
      #if show-num [
        #text(size: 11pt, fill: accent, weight: "bold", tracking: 0.1em)[#upper(cfg.chapter-prefix) #num]
        #v(0.1em)
      ]
      #text(size: cfg.chapter-size, weight: "black", fill: primary)[#upper(title)]
    ]
  },

  section: (title, ch-num, sec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color

    block(width: 100%, above: 0pt, below: 0pt, stroke: (left: 3pt + accent), inset: (left: 0.8em, y: 0.2em))[
      #text(size: cfg.section-size, weight: "bold", fill: primary)[
        #if show-num [#text(fill: accent)[#sec-num.]#h(0.3em)]
        #upper(title)
      ]
    ]
  },

  subsection: (title, ch-num, sec-num, subsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color
    text(size: cfg.subsection-size, weight: "bold", fill: primary)[
      #if show-num [#text(fill: accent)[#sec-num.#subsec-num]#h(0.4em)]
      #title
    ]
  },

  subsubsection: (title, sec-num, subsec-num, subsubsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    text(size: cfg.subsubsection-size, weight: "semibold", fill: primary)[
      #if show-num [#sec-num.#subsec-num.#subsubsec-num#h(0.4em)]
      #title
    ]
  },
)
