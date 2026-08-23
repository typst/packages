// Style: Magazine
// ============================================================================
// Editorial style with prominent numbers
// PRINT-FRIENDLY: outline numbers, no fills
// ============================================================================

#let style-magazine = (
  chapter: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color
    let secondary = cfg.secondary-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #if show-num [
        #text(size: 72pt, weight: "bold", fill: secondary.lighten(60%))[#numbering("01", num)]
        #v(-2.5em)
      ]
      #text(size: 10pt, fill: accent, weight: "bold", tracking: 0.15em)[#upper(cfg.chapter-prefix)]
      #v(0.2em)
      #text(size: cfg.chapter-size, weight: "black", fill: primary)[#title]
      #v(0.2em)
      #line(length: 100%, stroke: 1.5pt + primary)
    ]
  },

  section: (title, ch-num, sec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color
    let secondary = cfg.secondary-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #if show-num [
        #text(size: 9pt, fill: accent, weight: "bold", tracking: 0.1em)[#upper(cfg.section-prefix) #sec-num]
        #v(0.1em)
      ]
      #text(size: cfg.section-size, weight: "bold", fill: primary)[#title]
      #v(0.1em)
      #grid(
        columns: (2.5em, 1fr),
        line(length: 100%, stroke: 2pt + accent),
        line(length: 100%, stroke: 0.5pt + secondary),
      )
    ]
  },

  subsection: (title, ch-num, sec-num, subsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    grid(
      columns: (auto, 1fr),
      gutter: 0.5em,
      align: (center + top, left + horizon),
      [
        #if show-num [
          #text(size: 18pt, weight: "bold", fill: secondary)[#subsec-num]
        ] else [
          #text(size: 12pt, fill: cfg.accent-color)[■]
        ]
      ],
      text(size: cfg.subsection-size, weight: "bold", fill: primary)[#title],
    )
  },

  subsubsection: (title, sec-num, subsec-num, subsubsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color
    text(size: cfg.subsubsection-size, fill: primary)[
      #text(weight: "bold", fill: accent)[▸]#h(0.2em)
      #text(weight: "semibold")[#title]
    ]
  },
)
