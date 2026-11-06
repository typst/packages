// Style: Vintage
// ============================================================================
// Classic book style with ornamental elements
// PRINT-FRIENDLY: text ornaments only
// ============================================================================

#let style-vintage = (
  chapter: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #align(center)[
        #text(size: 8pt, fill: secondary)[✦ ✦ ✦]
        #v(0.4em)
        #if show-num [
          #text(size: 10pt, style: "italic", fill: secondary)[#cfg.chapter-prefix]
          #v(0.2em)
          #text(size: 32pt, fill: secondary.lighten(30%))[#numbering("I", num)]
          #v(0.3em)
        ]
        #line(length: 6em, stroke: 0.4pt + secondary)
        #v(0.4em)
        #text(size: cfg.chapter-size, style: "italic", fill: primary)[#title]
        #v(0.4em)
        #text(size: 10pt, fill: secondary)[— ❦ —]
      ]
    ]
  },

  section: (title, ch-num, sec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    block(width: 100%, above: 0pt, below: 0pt)[
      #align(center)[
        #text(size: 8pt, fill: secondary)[§]
        #h(0.2em)
        #if show-num [
          #text(size: 10pt, fill: secondary)[#numbering("I", sec-num).]
          #h(0.3em)
        ]
        #text(size: cfg.section-size, style: "italic", fill: primary)[#title]
        #h(0.2em)
        #text(size: 8pt, fill: secondary)[§]
      ]
    ]
  },

  subsection: (title, ch-num, sec-num, subsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    text(fill: primary)[
      #text(size: 8pt, fill: secondary)[❧]#h(0.3em)
      #if show-num [#text(size: 10pt, style: "italic", fill: secondary)[#numbering("i", subsec-num).]#h(0.2em)]
      #text(size: cfg.subsection-size, style: "italic")[#title]
    ]
  },

  subsubsection: (title, sec-num, subsec-num, subsubsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color

    pad(left: 1em)[
      #text(size: cfg.subsubsection-size, style: "italic", fill: primary)[
        #if show-num [#text(fill: secondary)[(#numbering("a", subsubsec-num))]#h(0.2em)]
        #title
      ]
    ]
  },
)
