// Style: Educational
// ============================================================================
// Modern educational style with left border and colored numbers
// PRINT-FRIENDLY: colored numbers, clean structure
// ============================================================================

#import "../typography.typ": part-number, chapter-number, section-number, subsection-number, subsubsection-number

#let style-educational = (
  part: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color

    block(width: 100%, above: 0pt, below: 0pt, stroke: (left: 5pt + accent), inset: (left: 1.2em, y: 0.5em))[
      #if show-num [
        #text(size: 42pt, weight: "bold", fill: accent.lighten(35%))[#part-number(num, cfg)]
        #v(-0.35em)
        #text(size: 10pt, weight: "bold", fill: accent, tracking: 0.14em)[#upper(cfg.part-prefix)]
        #v(0.15em)
      ]
      #text(size: cfg.part-size, weight: "bold", fill: primary)[#title]
    ]
  },

  chapter: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color

    block(width: 100%, above: 0pt, below: 0pt, stroke: (left: 3pt + accent), inset: (left: 1em, y: 0.3em))[
      #if show-num [
        #text(size: 36pt, weight: "bold", fill: accent)[#chapter-number(num, cfg)]
        #v(-0.3em)
      ]
      #text(size: cfg.chapter-size, weight: "bold", fill: primary)[#title]
    ]
  },

  section: (title, ch-num, sec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #text(size: cfg.section-size, weight: "bold", fill: primary)[
        #if show-num [#text(fill: accent)[#section-number(ch-num, sec-num, cfg, fallback: [#ch-num.#sec-num])]#h(0.6em)]
        #title
      ]
      #v(-0.15em)
      #box(width: 3em, height: 2pt, fill: accent)
    ]
  },

  subsection: (title, ch-num, sec-num, subsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color

    text(size: cfg.subsection-size, weight: "bold", fill: primary)[
      #if show-num [#text(fill: accent)[#subsection-number(ch-num, sec-num, subsec-num, cfg, fallback: [#ch-num.#str(sec-num)#"\u{2060}.\u{2060}"#str(subsec-num)])]#h(0.5em)]
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
