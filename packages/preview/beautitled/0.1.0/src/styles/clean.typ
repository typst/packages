// Style: Clean
// ============================================================================
// Very clean and simple, maximum readability
// PRINT-FRIENDLY: minimal ink, pure text
// ============================================================================

#let style-clean = (
  chapter: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color

    text(size: cfg.chapter-size, weight: "bold", fill: primary)[
      #if show-num [#num.#h(0.5em)]
      #title
    ]
  },

  section: (title, ch-num, sec-num, cfg, show-num) => {
    let primary = cfg.primary-color

    text(size: cfg.section-size, weight: "bold", fill: primary)[
      #if show-num [#sec-num.#h(0.5em)]
      #title
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

    text(size: cfg.subsubsection-size, weight: "medium", fill: primary)[
      #if show-num [#sec-num.#subsec-num.#subsubsec-num#h(0.4em)]
      #title
    ]
  },
)
