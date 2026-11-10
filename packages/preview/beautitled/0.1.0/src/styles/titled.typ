// Style: Titled (Original/Default)
// ============================================================================
// The original titled style - boxed sections with floating labels
// Perfect for school documents, exercises, and educational materials
// PRINT-FRIENDLY: thin strokes only
// ============================================================================

#let titled-chapter-info = state("titled-chapter-info", (num: none, title: none))

#let style-titled = (
  chapter: (title, num, cfg, show-num) => {
    let primary = cfg.primary-color
    // Store chapter info for section labels (both number and title)
    if show-num {
      titled-chapter-info.update((num: num, title: title))
    } else {
      titled-chapter-info.update((num: none, title: title))
    }

    block(width: 100%, above: 0pt, below: 0pt)[
      #align(center)[
        #text(size: cfg.chapter-size, weight: "bold", fill: primary)[
          #if show-num [#cfg.chapter-prefix #num : ]
          #title
        ]
      ]
    ]
  },

  section: (title, ch-num, sec-num, cfg, show-num) => context {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color
    let show-ch = cfg.at("show-chapter-in-section", default: true)
    let ch-info = titled-chapter-info.get()

    let label-text = text(size: 9pt, weight: "regular", fill: secondary)[
      #if show-ch and ch-info.num != none [
        Ch. #ch-info.num : #ch-info.title #h(0.3em) — #h(0.3em)
      ]
      #if show-num [#text(tracking: 0.1em)[#upper(cfg.section-prefix) #sec-num]]
    ]

    block(width: 100%, above: 0pt, below: 0pt, stroke: 0.8pt + primary, inset: (x: 1em, y: 0.8em))[
      #place(top + left, dy: -1em - 2.5pt, dx: 0pt)[
        #box(fill: white, inset: (x: 2pt, y: 2pt))[#label-text]
      ]
      #align(center)[#text(size: cfg.section-size, weight: "bold", fill: primary)[#title]]
    ]
  },

  subsection: (title, ch-num, sec-num, subsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    text(size: cfg.subsection-size, weight: "bold", fill: primary)[
      #if show-num [#sec-num.#subsec-num #h(0.5em)]
      #title
    ]
  },

  subsubsection: (title, sec-num, subsec-num, subsubsec-num, cfg, show-num) => {
    let primary = cfg.primary-color
    text(size: cfg.subsubsection-size, weight: "semibold", fill: primary)[
      #if show-num [#sec-num.#subsec-num.#subsubsec-num #h(0.4em)]
      #title
    ]
  },
)
