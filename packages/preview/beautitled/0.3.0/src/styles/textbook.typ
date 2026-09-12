// Style: Textbook
// ============================================================================
// Bold numbers with clear hierarchy, ideal for textbooks
// PRINT-FRIENDLY: accent color used sparingly
// ============================================================================

#import "../typography.typ": part-number, chapter-number, section-number, subsection-number, subsubsection-number

#let style-textbook = (
  part: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #grid(
        columns: (auto, 1fr),
        gutter: 1em,
        align: (right + top, left + top),
        [
          #if show-num [
            #text(size: 56pt, weight: "bold", fill: accent.lighten(60%))[#part-number(num, cfg)]
          ]
        ],
        [
          #if show-num [
            #text(size: 10pt, fill: accent, weight: "medium", tracking: 0.14em)[#upper(cfg.part-prefix)]
            #v(0.25em)
          ]
          #text(size: cfg.part-size, weight: "bold", fill: primary)[#title]
        ],
      )
      #v(0.3em)
      #line(length: 100%, stroke: 1pt + accent)
    ]
  },

  chapter: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #grid(
        columns: (auto, 1fr),
        gutter: 1em,
        align: (right + top, left + top),
        [
          #if show-num [
            #text(size: 48pt, weight: "bold", fill: accent.lighten(60%))[#chapter-number(num, cfg)]
          ]
        ],
        [
          #if show-num [
            #text(size: 10pt, fill: accent, weight: "medium", tracking: 0.1em)[#upper(cfg.chapter-prefix)]
            #v(0.2em)
          ]
          #text(size: cfg.chapter-size, weight: "bold", fill: primary)[#title]
        ],
      )
      #v(0.2em)
      #line(length: 100%, stroke: 0.8pt + accent)
    ]
  },

  section: (title, ch-num, sec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color

    text(size: cfg.section-size, weight: "bold", fill: primary)[
      #if show-num [#text(fill: accent)[#section-number(ch-num, sec-num, cfg, fallback: [#sec-num])]#h(0.6em)]
      #title
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
