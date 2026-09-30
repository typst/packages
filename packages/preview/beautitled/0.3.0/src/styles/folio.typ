// Style: Folio
// ============================================================================
// Contemporary editorial typography with a quiet oversized chapter number.
// PRINT-FRIENDLY: type-led, with only two fine rules.
// ============================================================================

#import "../typography.typ": heading-face, part-number, chapter-number, section-number, subsection-number, subsubsection-number

#let style-folio = (
  part: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color
    let accent = cfg.accent-color

    heading-face(cfg)[
      #block(width: 100%, above: 0pt, below: 0pt)[
        #align(center)[
          #line(length: 62%, stroke: 0.5pt + secondary.lighten(30%))
          #v(0.8em)
          #if show-num [
            #text(size: 8.5pt, weight: "semibold", fill: accent, tracking: 0.2em)[
              #upper(cfg.part-prefix) #part-number(num, cfg)
            ]
            #v(0.55em)
          ]
          #text(size: cfg.part-size + 4pt, weight: "regular", fill: primary)[#title]
          #v(0.8em)
          #line(length: 62%, stroke: 0.5pt + secondary.lighten(30%))
        ]
      ]
    ]
  },

  chapter: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color
    let accent = cfg.accent-color

    heading-face(cfg)[
      #block(width: 100%, above: 0pt, below: 0pt)[
        #line(length: 100%, stroke: 0.5pt + secondary.lighten(30%))
        #v(0.55em)
        #grid(
          columns: (1fr, auto),
          gutter: 1em,
          align: (left + bottom, right + bottom),
          [
            #text(size: 8pt, weight: "semibold", fill: accent, tracking: 0.18em)[#upper(cfg.chapter-prefix)]
            #v(0.25em)
            #text(size: cfg.chapter-size + 7pt, weight: "regular", fill: primary)[#title]
          ],
          if show-num {
            text(size: cfg.chapter-size + 14pt, weight: "light", fill: secondary.lighten(28%))[
              #chapter-number(num, cfg, fallback: [#numbering("01", num)])
            ]
          } else {
            text(size: cfg.chapter-size + 5pt, fill: accent)[·]
          },
        )
        #v(0.55em)
        #line(length: 100%, stroke: 0.8pt + primary)
      ]
    ]
  },

  section: (title, ch-num, sec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color
    let accent = cfg.accent-color

    heading-face(cfg)[
      #block(width: 100%, above: 0pt, below: 0pt)[
        #if show-num [
          #text(size: 8pt, weight: "semibold", fill: accent, tracking: 0.13em)[
            #upper(cfg.section-prefix) #section-number(ch-num, sec-num, cfg, fallback: [#sec-num])
          ]
          #v(0.16em)
        ]
        #text(size: cfg.section-size + 1pt, weight: "medium", fill: primary)[#title]
        #v(0.18em)
        #line(length: 2.4em, stroke: 0.6pt + secondary)
      ]
    ]
  },

  subsection: (title, ch-num, sec-num, subsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    heading-face(cfg)[
      #text(size: cfg.subsection-size, weight: "medium", fill: primary)[
        #if show-num [
          #text(size: 0.82em, fill: secondary)[
            #subsection-number(ch-num, sec-num, subsec-num, cfg, fallback: [#str(sec-num)#"\u{2060}.\u{2060}"#str(subsec-num)])
          ]
          #h(0.7em)
        ]
        #title
      ]
    ]
  },

  subsubsection: (title, ch-num, sec-num, subsec-num, subsubsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    heading-face(cfg)[
      #text(size: cfg.subsubsection-size, style: "italic", fill: primary)[
        #if show-num [
          #text(style: "normal", fill: secondary)[
            #subsubsection-number(ch-num, sec-num, subsec-num, subsubsec-num, cfg, fallback: [#str(sec-num)#"\u{2060}.\u{2060}"#str(subsec-num)#"\u{2060}.\u{2060}"#str(subsubsec-num)])
          ]
          #h(0.55em)
        ]
        #title
      ]
    ]
  },
)
