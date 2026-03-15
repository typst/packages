// Style: Educational
// ============================================================================
// Modern educational style with left border and colored numbers
// PRINT-FRIENDLY: colored numbers, clean structure
// ============================================================================

#let style-educational = (
  chapter: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color

    block(width: 100%, above: 0pt, below: 0pt, stroke: (left: 3pt + accent), inset: (left: 1em, y: 0.3em))[
      #if show-num [
        #text(size: 36pt, weight: "bold", fill: accent)[#num]
        #v(-0.3em)
      ]
      #text(size: cfg.chapter-size, weight: "bold", fill: primary)[#title]
    ]
  },

  section: (title, ch-num, sec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #text(size: cfg.section-size, weight: "bold", fill: primary)[
        #if show-num [#text(fill: accent)[#ch-num.#sec-num]#h(0.6em)]
        #title
      ]
      #v(-0.15em)
      #box(width: 3em, height: 2pt, fill: accent)
    ]
  },

  subsection: (title, ch-num, sec-num, subsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color

    text(size: cfg.subsection-size, weight: "bold", fill: primary)[
      #if show-num [#text(fill: accent)[#ch-num.#sec-num.#subsec-num]#h(0.5em)]
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
