// Style: Structured
// ============================================================================
// Clear structured style with boxed chapter numbers
// PRINT-FRIENDLY: boxed chapter numbers, simple lines
// ============================================================================

#import "../typography.typ": part-number, chapter-number, section-number, subsection-number, subsubsection-number

#let style-structured = (
  part: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #grid(
        columns: (auto, 1fr),
        gutter: 1em,
        align: horizon,
        [
          #if show-num [
            #box(stroke: 1.8pt + accent, inset: 0.6em)[
              #text(size: 24pt, weight: "bold", fill: accent)[#part-number(num, cfg)]
            ]
          ]
        ],
        [
          #text(size: 10pt, weight: "bold", fill: accent, tracking: 0.14em)[#upper(cfg.part-prefix)]
          #v(0.15em)
          #text(size: cfg.part-size, weight: "bold", fill: primary)[#title]
        ],
      )
      #v(0.35em)
      #line(length: 100%, stroke: 1pt + primary)
    ]
  },

  chapter: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #grid(
        columns: (auto, 1fr),
        gutter: 0.8em,
        align: horizon,
        [
          #if show-num [
            #box(stroke: 1.5pt + accent, inset: 0.5em)[
              #text(size: 20pt, weight: "bold", fill: accent)[#chapter-number(num, cfg)]
            ]
          ]
        ],
        [
          #text(size: cfg.chapter-size, weight: "bold", fill: primary)[#title]
        ],
      )
      #v(0.3em)
      #line(length: 100%, stroke: 0.8pt + primary)
    ]
  },

  section: (title, ch-num, sec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #grid(
        columns: (auto, 1fr),
        gutter: 0.6em,
        align: horizon,
        [
          #if show-num [
            #box(stroke: 1.2pt + accent, inset: 0.4em)[
              #text(size: 14pt, weight: "bold", fill: accent)[#section-number(ch-num, sec-num, cfg, fallback: [#sec-num])]
            ]
          ]
        ],
        [
          #text(size: cfg.section-size, weight: "bold", fill: primary)[#title]
        ],
      )
    ]
  },

  subsection: (title, ch-num, sec-num, subsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    text(size: cfg.subsection-size, weight: "bold", fill: primary)[
      #if show-num [#text(fill: secondary)[#subsection-number(ch-num, sec-num, subsec-num, cfg, fallback: [#str(sec-num)#"\u{2060}.\u{2060}"#str(subsec-num)])]#h(0.5em)]
      #title
    ]
  },

  subsubsection: (title, ch-num, sec-num, subsec-num, subsubsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    text(size: cfg.subsubsection-size, weight: "semibold", fill: primary)[
      #if show-num [#text(fill: secondary)[#subsubsection-number(ch-num, sec-num, subsec-num, subsubsec-num, cfg, fallback: [#str(sec-num)#"\u{2060}.\u{2060}"#str(subsec-num)#"\u{2060}.\u{2060}"#str(subsubsec-num)])]#h(0.4em)]
      #title
    ]
  },
)
