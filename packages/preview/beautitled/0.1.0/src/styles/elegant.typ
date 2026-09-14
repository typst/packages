// Style: Elegant
// ============================================================================
// Refined style with thin decorative elements
// PRINT-FRIENDLY: thin lines and small symbols only
// ============================================================================

#let style-elegant = (
  chapter: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #align(center)[
        #text(size: 8pt, fill: secondary)[— ✦ —]
        #v(0.5em)
        #if show-num [
          #text(size: 10pt, fill: secondary, tracking: 0.2em)[#smallcaps[#cfg.chapter-prefix]]
          #h(0.3em)
          #text(size: 28pt, fill: secondary.lighten(30%))[#numbering("I", num)]
          #v(0.3em)
        ]
        #text(size: cfg.chapter-size, fill: primary, tracking: 0.05em)[#smallcaps[#title]]
        #v(0.5em)
        #text(size: 8pt, fill: secondary)[— ✦ —]
      ]
    ]
  },

  section: (title, ch-num, sec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #align(center)[
        #line(length: 2em, stroke: 0.4pt + secondary)
        #h(0.8em)
        #text(size: cfg.section-size, fill: primary, tracking: 0.1em)[
          #if show-num [#text(fill: secondary)[#numbering("i", sec-num).] #h(0.3em)]
          #smallcaps[#title]
        ]
        #h(0.8em)
        #line(length: 2em, stroke: 0.4pt + secondary)
      ]
    ]
  },

  subsection: (title, ch-num, sec-num, subsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color
    text(size: cfg.subsection-size, fill: primary)[
      #text(fill: secondary)[§]#h(0.3em)
      #if show-num [#text(style: "italic", fill: secondary)[#sec-num.#subsec-num]#h(0.3em)]
      #emph[#title]
    ]
  },

  subsubsection: (title, sec-num, subsec-num, subsubsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color
    text(size: cfg.subsubsection-size, style: "italic", fill: primary)[
      #if show-num [#text(fill: secondary)[#sec-num.#subsec-num.#subsubsec-num]#h(0.3em)]
      #title
    ]
  },
)
