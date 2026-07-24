// Style: Notes
// ============================================================================
// Optimized for course notes and study materials
// PRINT-FRIENDLY: very light, easy to annotate
// ============================================================================

#import "../typography.typ": part-number, chapter-number, section-number, subsection-number, subsubsection-number

#let style-notes = (
  part: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #if show-num [
        #text(size: 10pt, fill: secondary, tracking: 0.12em)[#upper(cfg.part-prefix) #part-number(num, cfg)]
        #h(0.4em)
        #text(fill: secondary)[|]
        #h(0.4em)
      ]
      #text(size: cfg.part-size, weight: "bold", fill: primary)[#title]
      #v(0.15em)
      #line(length: 6em, stroke: 0.6pt + secondary)
    ]
  },

  chapter: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #if show-num [
        #text(size: 10pt, fill: secondary)[#cfg.chapter-prefix #chapter-number(num, cfg)]
        #h(0.3em)
        #text(fill: secondary)[|]
        #h(0.3em)
      ]
      #text(size: cfg.chapter-size, weight: "bold", fill: primary)[#title]
    ]
  },

  section: (title, ch-num, sec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #text(size: cfg.section-size, weight: "bold", fill: primary)[
        #if show-num [#text(fill: secondary)[#section-number(ch-num, sec-num, cfg, fallback: [#sec-num.])]#h(0.4em)]
        #title
      ]
      #v(-0.2em)
      #line(length: 4em, stroke: 0.5pt + secondary)
    ]
  },

  subsection: (title, ch-num, sec-num, subsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    text(size: cfg.subsection-size, weight: "semibold", fill: primary)[
      #if show-num [#text(fill: secondary)[#subsection-number(ch-num, sec-num, subsec-num, cfg, fallback: [#str(sec-num)#"\u{2060}.\u{2060}"#str(subsec-num)])]#h(0.4em)]
      #title
    ]
  },

  subsubsection: (title, ch-num, sec-num, subsec-num, subsubsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    text(size: cfg.subsubsection-size, fill: primary)[
      #text(fill: secondary)[•]#h(0.3em)
      #if show-num [#text(fill: secondary)[#subsubsection-number(ch-num, sec-num, subsec-num, subsubsec-num, cfg, fallback: [#str(sec-num)#"\u{2060}.\u{2060}"#str(subsec-num)#"\u{2060}.\u{2060}"#str(subsubsec-num)])]#h(0.3em)]
      #title
    ]
  },
)
