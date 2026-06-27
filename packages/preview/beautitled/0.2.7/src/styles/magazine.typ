// Style: Magazine
// ============================================================================
// Editorial style with prominent numbers
// PRINT-FRIENDLY: outline numbers, no fills
// ============================================================================

#import "../typography.typ": part-number, chapter-number, section-number, subsection-number, subsubsection-number

#let style-magazine = (
  part: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color
    let secondary = cfg.secondary-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #if show-num [
        #text(size: 84pt, weight: "bold", fill: secondary.lighten(65%))[#part-number(num, cfg)]
        #v(-2.6em)
      ]
      #text(size: 10pt, fill: accent, weight: "bold", tracking: 0.18em)[#upper(cfg.part-prefix)]
      #v(0.25em)
      #text(size: cfg.part-size, weight: "black", fill: primary)[#title]
      #v(0.25em)
      #line(length: 100%, stroke: 2pt + primary)
    ]
  },

  chapter: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color
    let secondary = cfg.secondary-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #if show-num [
        #text(size: 72pt, weight: "bold", fill: secondary.lighten(60%))[#chapter-number(num, cfg, fallback: [#numbering("01", num)])]
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
        #text(size: 9pt, fill: accent, weight: "bold", tracking: 0.1em)[#upper(cfg.section-prefix) #section-number(ch-num, sec-num, cfg, fallback: [#sec-num])]
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
          #text(size: 18pt, weight: "bold", fill: secondary)[#subsection-number(ch-num, sec-num, subsec-num, cfg, fallback: [#subsec-num])]
        ] else [
          #text(size: 12pt, fill: cfg.accent-color)[■]
        ]
      ],
      text(size: cfg.subsection-size, weight: "bold", fill: primary)[#title],
    )
  },

  subsubsection: (title, ch-num, sec-num, subsec-num, subsubsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color
    text(size: cfg.subsubsection-size, fill: primary)[
      #text(weight: "bold", fill: accent)[▸]#h(0.2em)
      #if show-num [#text(fill: cfg.secondary-color)[#subsubsection-number(ch-num, sec-num, subsec-num, subsubsec-num, cfg, fallback: [#str(sec-num)#"\u{2060}.\u{2060}"#str(subsec-num)#"\u{2060}.\u{2060}"#str(subsubsec-num)])]#h(0.3em)]
      #text(weight: "semibold")[#title]
    ]
  },
)
