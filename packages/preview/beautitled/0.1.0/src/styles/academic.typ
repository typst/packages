// Style: Academic
// ============================================================================
// Clean, professional academic style with underlined chapters
// PRINT-FRIENDLY: thin lines, no heavy fills
// ============================================================================

#let style-academic = (
  chapter: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #if show-num [
        #text(size: 11pt, fill: secondary, weight: "medium")[#cfg.chapter-prefix #num]
        #v(0.3em)
      ]
      #text(size: cfg.chapter-size + 4pt, weight: "bold", fill: primary)[#title]
      #v(0.4em)
      #line(length: 100%, stroke: 1.2pt + primary)
    ]
  },

  section: (title, ch-num, sec-num, cfg, show-num) => {
    let primary = cfg.primary-color

    text(size: cfg.section-size, weight: "bold", fill: primary)[
      #if show-num [#ch-num.#sec-num#h(0.8em)]
      #title
    ]
  },

  subsection: (title, ch-num, sec-num, subsec-num, cfg, show-num) => {
    let primary = cfg.primary-color

    text(size: cfg.subsection-size, weight: "bold", fill: primary)[
      #if show-num [#ch-num.#sec-num.#subsec-num#h(0.6em)]
      #title
    ]
  },

  subsubsection: (title, sec-num, subsec-num, subsubsec-num, cfg, show-num) => {
    let primary = cfg.primary-color

    text(size: cfg.subsubsection-size, weight: "semibold", style: "italic", fill: primary)[
      #if show-num [#sec-num.#subsec-num.#subsubsec-num#h(0.5em)]
      #title
    ]
  },
)
