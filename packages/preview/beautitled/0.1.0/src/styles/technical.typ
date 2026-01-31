// Style: Technical
// ============================================================================
// Engineering/documentation style with clear structure
// PRINT-FRIENDLY: thin borders, no fills
// ============================================================================

#let style-technical = (
  chapter: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    block(width: 100%, above: 0pt, below: 0pt, stroke: (left: 1.5pt + primary, bottom: 0.5pt + secondary), inset: (left: 1em, bottom: 0.5em, y: 0.5em))[
      #if show-num [
        #text(size: 9pt, fill: secondary, tracking: 0.1em)[#upper(cfg.chapter-prefix)]
        #h(0.3em)
        #text(size: 16pt, weight: "bold", fill: primary)[#num]
        #v(0.1em)
      ]
      #text(size: cfg.chapter-size, weight: "bold", fill: primary)[#title]
    ]
  },

  section: (title, ch-num, sec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    grid(
      columns: (auto, 1fr),
      gutter: 0.6em,
      align: horizon,
      [
        #if show-num [
          #box(stroke: 0.8pt + primary, inset: (x: 0.4em, y: 0.2em))[
            #text(size: 10pt, weight: "bold", fill: primary)[#if ch-num > 0 [#ch-num.]#sec-num]
          ]
        ]
      ],
      text(size: cfg.section-size, weight: "bold", fill: primary)[#title],
    )
    v(-0.2em)
    line(length: 100%, stroke: (paint: secondary, thickness: 0.5pt, dash: "dotted"))
  },

  subsection: (title, ch-num, sec-num, subsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    text(size: cfg.subsection-size, weight: "bold", fill: primary)[
      #if show-num [
        #text(size: 9pt, fill: secondary)[#if ch-num > 0 [#ch-num.]#sec-num.#subsec-num]
        #h(0.5em)
      ]
      #title
    ]
  },

  subsubsection: (title, sec-num, subsec-num, subsubsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    pad(left: 0.8em)[
      #text(size: cfg.subsubsection-size, weight: "semibold", fill: primary)[
        #if show-num [#text(size: 9pt, fill: secondary)[#sec-num.#subsec-num.#subsubsec-num]#h(0.4em)]
        #title
      ]
    ]
  },
)
