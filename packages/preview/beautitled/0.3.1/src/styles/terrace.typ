// Style: Terrace
// ============================================================================
// A lower-set asymmetric lockup. The number is optically coupled to the title
// through a tight two-column grid instead of floating elsewhere on the line.
// ============================================================================

#import "../typography.typ": heading-face, part-number, chapter-number, section-number, subsection-number, subsubsection-number

#let style-terrace = (
  part: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color
    let accent = cfg.accent-color
    heading-face(cfg)[
      #grid(
        columns: (auto, 1fr),
        gutter: 0.9em,
        align: (right + top, left + top),
        if show-num {
          text(size: cfg.part-size + 11pt, weight: "light", fill: accent)[#part-number(num, cfg)]
        } else {
          box(width: 0.32em, height: cfg.part-size + 7pt, fill: accent)
        },
        [
          #text(size: 8.5pt, weight: "semibold", fill: secondary, tracking: 0.14em)[#upper(cfg.part-prefix)]
          #v(0.12em)
          #text(size: cfg.part-size + 3pt, weight: "medium", fill: primary)[#title]
          #v(0.48em)
          #line(length: 100%, stroke: 0.5pt + secondary.lighten(35%))
        ],
      )
    ]
  },

  chapter: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color
    let accent = cfg.accent-color
    heading-face(cfg)[
      #block(width: 100%, above: 0pt, below: 0pt)[
        #grid(
          columns: (auto, 1fr),
          gutter: 0.85em,
          align: (right + top, left + top),
          if show-num {
            text(size: cfg.chapter-size + 13pt, weight: "light", fill: accent)[
              #chapter-number(num, cfg, fallback: [#numbering("01", num)])
            ]
          } else {
            box(width: 0.3em, height: cfg.chapter-size + 9pt, fill: accent)
          },
          [
            #text(size: 8pt, weight: "semibold", fill: secondary, tracking: 0.15em)[#upper(cfg.chapter-prefix)]
            #v(0.1em)
            #text(size: cfg.chapter-size + 5pt, weight: "medium", fill: primary)[#title]
          ],
        )
        #v(0.48em)
        #grid(
          columns: (3.2em, 1fr),
          gutter: 0.45em,
          line(length: 100%, stroke: 1.2pt + accent),
          line(length: 100%, stroke: 0.45pt + secondary.lighten(38%)),
        )
      ]
    ]
  },

  section: (title, ch-num, sec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color
    let accent = cfg.accent-color
    heading-face(cfg)[
      #grid(
        columns: (auto, 1fr),
        gutter: 0.65em,
        align: (right + horizon, left + horizon),
        if show-num {
          text(size: 9pt, weight: "semibold", fill: accent)[
            #section-number(ch-num, sec-num, cfg, fallback: [#sec-num])
          ]
        } else {
          line(length: 1em, stroke: 1pt + accent)
        },
        block(width: 100%, below: 0pt)[
          #text(size: cfg.section-size, weight: "semibold", fill: primary)[#title]
          #v(0.15em)
          #line(length: 100%, stroke: 0.4pt + secondary.lighten(45%))
        ],
      )
    ]
  },

  subsection: (title, ch-num, sec-num, subsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color
    heading-face(cfg)[
      #text(size: cfg.subsection-size, weight: "medium", fill: primary)[
        #if show-num [
          #text(size: 0.8em, weight: "semibold", fill: accent)[
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
