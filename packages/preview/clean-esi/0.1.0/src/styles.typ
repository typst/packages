// src/styles.typ - ESI Algiers thesis styling rules
// Following ESI standards and LaTeX reference for typography

#import "colors.typ": *
#import "tables.typ": thesis-table-align, thesis-table-fill, thesis-table-inset, thesis-table-stroke

// ══════════════════════════════════════════════════════════════════════════════
// HEADING RENDERERS (shared)
// Extracted so the same visual rules can be applied at a shifted level inside the
// Part wrappers (`numbered-part` in conf.typ), where chapters live at level 2,
// sections at level 3, etc. Keeping them here means the two regions can never
// drift apart stylistically.
// ══════════════════════════════════════════════════════════════════════════════

#let chapter-top-space = 4.0em
#let chapter-label-gap = 26pt
#let chapter-after-space = 24pt

// Chapter-style heading (24pt). Numbered → "Chapter N" + title; else just title.
#let chapter-heading(it) = context {
  set par(first-line-indent: 0pt, justify: false)
  set align(if text.dir == rtl { right } else { left })
  pagebreak(weak: true)

  if it.numbering != none {
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: "algorithm")).update(0)
    v(chapter-top-space)
    text(size: 24pt, weight: "bold")[Chapter #counter(heading).display()]
    v(chapter-label-gap)
    text(size: 24pt, weight: "bold")[#it.body]
    v(chapter-after-space)
  } else {
    v(chapter-top-space)
    text(size: 24pt, weight: "bold")[#it.body]
    v(chapter-after-space)
  }
}

// Section-style heading (18pt).
#let section-heading(it) = {
  set par(first-line-indent: 0pt, justify: false)
  block(above: 20pt, below: 12pt, sticky: true)[
    #text(size: 18pt, weight: "bold")[
      #if it.numbering != none {
        counter(heading).display()
        h(0.5em)
      }
      #it.body
    ]
  ]
}

// Subsection-style heading (14pt).
#let subsection-heading(it) = {
  set par(first-line-indent: 0pt, justify: false)
  block(above: 16pt, below: 9pt, sticky: true)[
    #text(size: 14pt, weight: "bold")[
      #if it.numbering != none {
        counter(heading).display()
        h(0.5em)
      }
      #it.body
    ]
  ]
}

// Sub-subsection-style heading (12pt bold italic).
#let subsubsection-heading(it) = {
  set par(first-line-indent: 0pt, justify: false)
  block(above: 10pt, below: 4pt, sticky: true)[
    #text(size: 12pt, weight: "bold", style: "italic")[
      #if it.numbering != none {
        counter(heading).display()
        h(0.5em)
      }
      #it.body
    ]
  ]
}

// ══════════════════════════════════════════════════════════════════════════════
// MAIN STYLE FUNCTION
// Usage: #show: apply-styles
// ══════════════════════════════════════════════════════════════════════════════

#let apply-styles(body) = {
  // ─────────────────────────────────────────────────────────────────────────────
  // ESI typography & spacing (centralized knobs)
  // - A4, margins handled in `lib/conf.typ`
  // - Body font: 12pt
  // - Line spacing target: ~1.5
  // These values are intentionally easy to tune if ESI updates guidance.
  // ─────────────────────────────────────────────────────────────────────────────
  let space-xs = 0.2em
  let space-sm = 0.35em
  let space-md = 0.5em
  let space-lg = 0.7em
  let space-xl = 1.1em
  let display-above = 1.15em
  let display-below = 1.15em
  let caption-gap = 0.42em
  let caption-size = 12pt
  let list-before-space = 0.8em

  // ════════════════════════════════════════════════════════════════════════════
  // TYPOGRAPHY - LaTeX Style (12pt, justified, French)
  // ════════════════════════════════════════════════════════════════════════════

  set text(
    font: ("New Computer Modern", "Linux Libertine", "Times New Roman"),
    size: 12pt,
    lang: "en",
    hyphenate: true,
    fill: text-dark,
  )

  set par(
    justify: true,
    first-line-indent: 18pt,
    // 1.5 line-spacing target with the guide's 6 pt paragraph gap.
    leading: 0.70em,
    spacing: 6pt,
    linebreaks: "optimized",
  )

  // ════════════════════════════════════════════════════════════════════════════
  // HEADINGS - ESI Standard
  // ════════════════════════════════════════════════════════════════════════════

  set heading(numbering: "1.1.1")

  // Level 1: Chapters · 2: Sections · 3: Subsections · 4: Sub-subsections.
  // Renderers are shared with the Part wrappers (see `numbered-part`).
  show heading.where(level: 1): set heading(supplement: [Chapter])
  show heading.where(level: 1): chapter-heading
  show heading.where(level: 2): section-heading
  show heading.where(level: 3): subsection-heading
  show heading.where(level: 4): subsubsection-heading

  // ════════════════════════════════════════════════════════════════════════════
  // CODE BLOCKS
  // ════════════════════════════════════════════════════════════════════════════

  show raw.where(block: true): it => {
    set text(font: ("Consolas", "Courier New", "DejaVu Sans Mono"), size: 10pt)
    block(
      fill: code-bg,
      stroke: 1pt + code-border,
      inset: 1em,
      radius: 4pt,
      width: 100%,
      above: space-sm,
      below: space-sm,
    )[#it]
  }

  show raw.where(block: false): it => {
    text(
      font: ("CMU Typewriter Text", "DejaVu Sans Mono", "Consolas", "Courier New"),
      size: 10pt,
      fill: rgb("#2f343a"),
    )[#it]
  }

  // ════════════════════════════════════════════════════════════════════════════
  // FIGURES & TABLES - ESI Standard
  // ════════════════════════════════════════════════════════════════════════════

  show figure.where(kind: image): set figure(numbering: "1")
  show figure.where(kind: table): set figure(numbering: n => {
    let chapter = counter(heading).get().at(0)
    numbering("1.1", chapter, n)
  })
  show figure.where(kind: "algorithm"): set figure(numbering: n => {
    let chapter = counter(heading).get().at(0)
    numbering("1.1", chapter, n)
  })

  // Figures: Caption BELOW
  show figure.where(kind: image): it => {
    set align(center)
    block(width: 100%, above: display-above, below: display-below)[
      #it.body
      #v(caption-gap)
      #set par(first-line-indent: 0pt)
      #text(size: caption-size)[*Figure #it.counter.display(it.numbering):* #it.caption.body]
    ]
  }

  // Tables: Caption ABOVE
  show figure.where(kind: table): it => {
    set align(center)
    block(width: 100%, above: display-above, below: display-below)[
      #set par(first-line-indent: 0pt)
      #text(size: caption-size)[*Table #it.counter.display(it.numbering):* #it.caption.body]
      #v(caption-gap)
      #it.body
    ]
  }

  // Algorithms: Caption BELOW
  show figure.where(kind: "algorithm"): it => {
    set align(center)
    block(width: 100%, above: display-above, below: display-below)[
      #it.body
      #if it.caption != none {
        v(caption-gap)
        set par(first-line-indent: 0pt)
        text(size: caption-size)[*Algorithm #it.counter.display(it.numbering):* #it.caption.body]
      }
    ]
  }

  set table(
    stroke: thesis-table-stroke,
    inset: thesis-table-inset,
    fill: thesis-table-fill,
    align: thesis-table-align,
  )
  show table.cell: it => {
    set par(justify: false, first-line-indent: 0pt, leading: 0.52em)
    set text(size: 9pt, hyphenate: true)
    it
  }
  show table.cell.where(y: 0): it => {
    set text(weight: "semibold")
    it
  }

  // ════════════════════════════════════════════════════════════════════════════
  // LISTS, LINKS, EQUATIONS
  // ════════════════════════════════════════════════════════════════════════════

  // Lists: keep compact, but readable under 1.5 line spacing.
  set list(indent: 1.5em, body-indent: 0.5em, marker: [•], spacing: 1em)
  set enum(indent: 1.5em, body-indent: 0.5em, spacing: 1em)

  // Option A: enforce a consistent vertical gap before lists/enums,
  // independent of whether the author inserted a blank line.
  show list: it => block(above: list-before-space)[#it]
  show enum: it => block(above: list-before-space)[#it]

  show cite: it => text(weight: "semibold")[#it]

  show link: it => {
    if type(it.dest) == str {
      // External links: black/dark-gray text, regular weight, no underline
      text(fill: text-dark, weight: "regular")[#it]
    } else {
      // Internal links (e.g. manual #link(<label>)[Chapter X]): bold, text-dark, no underline
      text(fill: text-dark, weight: "bold")[#it]
    }
  }

  show ref: set text(fill: text-dark, weight: "bold")

  show bibliography: it => {
    show link: it => text(fill: text-dark, weight: "regular")[#underline(it)]
    it
  }

  body
}
