// Style: Anchor
// ============================================================================
// Clarity-first chapter design: one alignment axis, one common-region rail,
// and a compact label-number tag held directly against the title.
// Whitespace creates hierarchy; decoration is deliberately limited.
// ============================================================================

#import "../typography.typ": heading-face, part-number, chapter-number, section-number, subsection-number, subsubsection-number

#let style-anchor = (
  part: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color
    heading-face(cfg)[
      #block(
        width: 100%,
        stroke: (left: 1.4pt + accent),
        inset: (left: 1.1em, y: 0.15em),
      )[
        #align(left)[
          #if show-num [
            #text(size: 8.5pt, weight: "semibold", fill: accent, tracking: 0.13em)[
              #upper(cfg.part-prefix) #part-number(num, cfg)
            ]
            #v(0.28em)
          ]
          #text(size: cfg.part-size + 5pt, weight: "medium", fill: primary)[#title]
        ]
      ]
    ]
  },

  chapter: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color
    heading-face(cfg)[
      #block(
        width: 100%,
        above: 0pt,
        below: 0pt,
        stroke: (left: 1.4pt + accent),
        inset: (left: 1.1em, y: 0.12em),
      )[
        #if show-num [
          #text(size: 8.5pt, weight: "semibold", fill: accent, tracking: 0.13em)[
            #upper(cfg.chapter-prefix) #chapter-number(num, cfg, fallback: [#numbering("01", num)])
          ]
          #v(0.26em)
        ]
        #text(size: cfg.chapter-size + 7pt, weight: "medium", fill: primary)[#title]
      ]
    ]
  },

  section: (title, ch-num, sec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color
    heading-face(cfg)[
      #block(width: 100%, stroke: (left: 0.9pt + accent), inset: (left: 0.72em, y: 0.08em))[
        #text(size: cfg.section-size, weight: "semibold", fill: primary)[
          #if show-num [
            #text(size: 0.72em, weight: "semibold", fill: accent)[
              #section-number(ch-num, sec-num, cfg, fallback: [#sec-num])
            ]
            #h(0.62em)
          ]
          #title
        ]
      ]
    ]
  },

  subsection: (title, ch-num, sec-num, subsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color
    heading-face(cfg)[
      #text(size: cfg.subsection-size, weight: "medium", fill: primary)[
        #if show-num [
          #text(size: 0.8em, weight: "semibold", fill: secondary)[
            #subsection-number(ch-num, sec-num, subsec-num, cfg, fallback: [#str(sec-num)#"\u{2060}.\u{2060}"#str(subsec-num)])
          ]
          #h(0.6em)
        ]
        #title
      ]
    ]
  },

  subsubsection: (title, ch-num, sec-num, subsec-num, subsubsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color
    heading-face(cfg)[
      #text(size: cfg.subsubsection-size, weight: "medium", fill: primary)[
        #if show-num [
          #text(fill: secondary)[
            #subsubsection-number(ch-num, sec-num, subsec-num, subsubsec-num, cfg, fallback: [#str(sec-num)#"\u{2060}.\u{2060}"#str(subsec-num)#"\u{2060}.\u{2060}"#str(subsubsec-num)])
          ]
          #h(0.5em)
        ]
        #title
      ]
    ]
  },
)
