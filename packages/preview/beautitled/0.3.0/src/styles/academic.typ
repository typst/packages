// Style: Academic
// ============================================================================
// Clean, professional academic style with underlined chapters
// PRINT-FRIENDLY: thin lines, no heavy fills
// ============================================================================

#import "../typography.typ": part-number, chapter-number, section-number, subsection-number, subsubsection-number

#let style-academic = (
  part: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #if show-num [
        #text(size: 12pt, fill: secondary, weight: "medium", tracking: 0.12em)[#upper(cfg.part-prefix) #part-number(num, cfg)]
        #v(0.5em)
      ]
      #text(size: cfg.part-size, weight: "bold", fill: primary)[#title]
      #v(0.5em)
      #line(length: 100%, stroke: 1.6pt + primary)
      #v(0.18em)
      #line(length: 100%, stroke: 0.5pt + secondary)
    ]
  },

  chapter: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #if show-num [
        #text(size: 11pt, fill: secondary, weight: "medium")[#cfg.chapter-prefix #chapter-number(num, cfg)]
        #v(0.3em)
      ]
      #text(size: cfg.chapter-size + 4pt, weight: "bold", fill: primary)[#title]
      #v(0.4em)
      #line(length: 100%, stroke: 1.2pt + primary)
    ]
  },

  section: (title, ch-num, sec-num, cfg, show-num) => {
    let primary = cfg.primary-color

    text(size: cfg.section-size, weight: "bold", fill: primary)[
      #if show-num [#section-number(ch-num, sec-num, cfg, fallback: [#ch-num.#sec-num])#h(0.8em)]
      #title
    ]
  },

  subsection: (title, ch-num, sec-num, subsec-num, cfg, show-num) => {
    let primary = cfg.primary-color

    text(size: cfg.subsection-size, weight: "bold", fill: primary)[
      #if show-num [#subsection-number(ch-num, sec-num, subsec-num, cfg, fallback: [#ch-num.#str(sec-num)#"\u{2060}.\u{2060}"#str(subsec-num)])#h(0.6em)]
      #title
    ]
  },

  subsubsection: (title, ch-num, sec-num, subsec-num, subsubsec-num, cfg, show-num) => {
    let primary = cfg.primary-color

    text(size: cfg.subsubsection-size, weight: "semibold", style: "italic", fill: primary)[
      #if show-num [#subsubsection-number(ch-num, sec-num, subsec-num, subsubsec-num, cfg, fallback: [#str(sec-num)#"\u{2060}.\u{2060}"#str(subsec-num)#"\u{2060}.\u{2060}"#str(subsubsec-num)])#h(0.5em)]
      #title
    ]
  },
)
