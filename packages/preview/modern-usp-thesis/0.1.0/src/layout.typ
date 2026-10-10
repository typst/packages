#import "@preview/drafting:0.2.2": inline-note, note-outline

// Layout settings for USP theses and dissertations

#let setup-layout(lang: "pt", body) = {
  // Paper and Margins
  set page(
    paper: "a4",
    margin: (
      top: 3cm,
      left: 3cm,
      right: 2cm,
      bottom: 2cm,
    ),
  )

  // Typography
  set text(
    size: 12pt,
    lang: lang,
  )

  // 1.5 line spacing (ABNT NBR 14724): an ~18pt baseline-to-baseline distance
  // at 12pt, as LaTeX's `\onehalfspacing`. Typst's leading is the gap between
  // the baseline and the next line's cap height (~0.7em), hence 0.8em.
  set par(
    leading: 0.8em,
    spacing: 1.5em,
    justify: true,
  )

  // Section numbering
  set heading(numbering: "1.1.1.1.1")
  
  // Section styling
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(1.5cm)
    set text(size: 14pt, weight: "bold")
    if it.numbering == none {
      // Pre-textual elements: Centered and All Caps
      align(center, upper(it.body))
    } else {
      // Textual chapters: Bold, 14pt, keep case as provided
      it
    }
    v(1.5cm)
  }

  show heading.where(level: 2): it => {
    v(1em)
    set text(size: 12pt, weight: "bold")
    it
    v(0.5em)
  }

  show heading.where(level: 3): it => {
    v(0.5em)
    set text(size: 12pt, weight: "bold")
    it
    v(0.5em)
  }

  // Table of Contents styling
  show outline.entry.where(level: 1): it => {
    v(1em, weak: true)
    // Lists of figures and tables (all level-1 entries) stay in regular weight.
    if it.element.func() == figure {
      it
    } else if it.element.func() == heading and it.element.numbering == "A.1" {
      // Appendix and annex entries read "APPENDIX A – Title" (see `appendix`).
      let n = numbering("A", ..counter(heading).at(it.element.location()))
      strong(link(it.element.location(), it.indented(
        none,
        [#upper[#it.element.supplement #n –] #it.inner()],
      )))
    } else if it.element.func() == heading and it.element.numbering == none {
      strong(upper(it))
    } else {
      strong(it)
    }
  }

  // References (ABNT NBR 6023): left-aligned, not justified, in the IME-USP
  // author-date style. A `style` passed to `bibliography` overrides it.
  set bibliography(style: read("usp-ime.csl", encoding: none))
  show bibliography: set par(justify: false)

  // Captions and Tables
  show figure: set text(size: 10pt)
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: image): set figure.caption(position: top) 

  body
}

// Special formatting for long quotes (> 3 lines)
#let quote-long(body) = {
  set text(size: 10pt)
  set par(leading: 0.5em, justify: true)
  pad(left: 4cm, body)
}

// Table helpers (booktabs style)
#let toprule = table.hline(stroke: 1.5pt)
#let midrule = table.hline(stroke: 0.8pt)
#let bottomrule = table.hline(stroke: 1.5pt)

// Appendices and annexes (ABNT NBR 14724): lettered numbering, referenced as
// "Appendix A", and the level-1 heading printed as "APPENDIX A – TITLE".
// Use `#show: appendix` (or `#show: annex`) before the first one; the
// numbering restarts at A.
#let appendix(supplement: auto, body) = {
  let supplement = if supplement == auto {
    context if text.lang == "pt" [Apêndice] else [Appendix]
  } else { supplement }
  set heading(numbering: "A.1")
  show heading.where(level: 1): set heading(supplement: supplement)
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(1.5cm)
    set text(size: 14pt, weight: "bold", hyphenate: false)
    set par(justify: false)
    align(center, upper[#it.supplement #counter(heading).display("A") – #it.body])
    v(1.5cm)
  }
  counter(heading).update(0)
  body
}

#let annex(body) = appendix(
  supplement: context if text.lang == "pt" [Anexo] else [Annex],
  body,
)

// Drafting / TODO notes. Notes are inline, highlighted in the running text:
// margin notes that overlap are pushed down through a state that needs one
// extra layout pass per overlapping note, so dense pages never converge. Each
// kind of note has its own color, which `#note-outline()` also shows.
#let todo-kinds = (
  write: (label: "Write", color: orange),
  results: (label: "Results", color: blue),
  decision: (label: "Decision", color: purple),
  source: (label: "Source", color: red),
  verify: (label: "Verify", color: rgb("#008b8b")),
  code: (label: "Code", color: rgb("#2e8b57")),
)

#let todo(kind: "write", content) = {
  assert(kind in todo-kinds, message: "unknown todo kind: " + kind)
  let (label, color) = todo-kinds.at(kind)
  inline-note(
    par-break: false,
    stroke: color + 1pt,
    fill: color.lighten(85%),
    text(size: 0.85em)[*#label:* #content],
  )
}
