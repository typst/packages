// Style: Schoolbook
// ============================================================================
// Textbook style optimized for course materials and lessons
// PRINT-FRIENDLY: simple lines, clear hierarchy
// ============================================================================

#import "../typography.typ": part-number, chapter-number, section-number, subsection-number, subsubsection-number

#let style-schoolbook = (
  part: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color

    block(width: 100%, above: 0pt, below: 0pt, stroke: (bottom: 2pt + accent), inset: (bottom: 0.65em))[
      #if show-num [
        #text(size: 12pt, fill: accent, weight: "bold", tracking: 0.1em)[#upper(cfg.part-prefix) #part-number(num, cfg)]
        #h(0.6em)
        #text(size: 12pt, fill: accent)[—]
        #h(0.6em)
      ]
      #text(size: cfg.part-size, weight: "bold", fill: primary)[#title]
    ]
  },

  chapter: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color

    block(width: 100%, above: 0pt, below: 0pt, stroke: (bottom: 1.5pt + accent), inset: (bottom: 0.5em))[
      #if show-num [
        #text(size: 12pt, fill: accent, weight: "bold")[#cfg.chapter-prefix #chapter-number(num, cfg)]
        #h(0.5em)
        #text(size: 12pt, fill: accent)[—]
        #h(0.5em)
      ]
      #text(size: cfg.chapter-size + 2pt, weight: "bold", fill: primary)[#title]
    ]
  },

  section: (title, ch-num, sec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #grid(
        columns: (auto, 1fr),
        gutter: 0.5em,
        align: horizon,
        [
          #if show-num [
            #text(size: cfg.section-size, weight: "bold", fill: accent)[#section-number(ch-num, sec-num, cfg, fallback: [#sec-num.])]
          ]
        ],
        [
          #text(size: cfg.section-size, weight: "bold", fill: primary)[#title]
        ],
      )
      #line(length: 100%, stroke: 0.5pt + primary.lighten(50%))
    ]
  },

  subsection: (title, ch-num, sec-num, subsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color

    text(size: cfg.subsection-size, weight: "semibold", fill: primary)[
      #if show-num [#text(fill: accent)[#subsection-number(ch-num, sec-num, subsec-num, cfg, fallback: [#str(sec-num)#"\u{2060}.\u{2060}"#str(subsec-num)])]#h(0.5em)]
      #title
    ]
  },

  subsubsection: (title, ch-num, sec-num, subsec-num, subsubsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    text(size: cfg.subsubsection-size, weight: "medium", fill: primary)[
      #if show-num [#text(fill: secondary)[#subsubsection-number(ch-num, sec-num, subsec-num, subsubsec-num, cfg, fallback: [#str(sec-num)#"\u{2060}.\u{2060}"#str(subsec-num)#"\u{2060}.\u{2060}"#str(subsubsec-num)])]#h(0.4em)]
      #title
    ]
  },
)
