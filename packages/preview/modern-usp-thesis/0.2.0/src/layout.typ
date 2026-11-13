#import "@preview/drafting:0.2.2": inline-note, note-outline

// Layout settings for USP theses and dissertations

// Page margins (USP Diretrizes 2.2.0, digital format), for every page.
#let usp-margin = (top: 3cm, left: 3cm, right: 2cm, bottom: 2cm)

#let setup-layout(lang: "pt", body) = {
  // Paper and Margins
  set page(
    paper: "a4",
    margin: usp-margin,
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
    // Footnotes are numbered per chapter, not restarting on each page
    // (USP Diretrizes 4.7).
    counter(footnote).update(0)
    v(1.5cm)
    if it.numbering == none {
      // Pre-textual elements: Centered and All Caps
      set text(size: 14pt, weight: "bold")
      align(center, upper(it.body))
    } else {
      // Textual chapters (IME-USP / LaTeX `book` look): a "Chapter N" line,
      // then the title on its own line, both left-aligned, bold and large.
      // The heading's own supplement is the localised "Chapter"/"Capítulo".
      set text(size: 24pt, weight: "bold", hyphenate: false)
      set par(justify: false, leading: 0.4em, spacing: 0.4em)
      block(width: 100%, {
        it.supplement
        [ ]
        numbering(it.numbering, ..counter(heading).at(it.location()))
        v(0.6cm, weak: true)
        it.body
      })
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

  // Table of Contents styling: the same emphasis and spelling as in the text.
  show outline.entry.where(level: 1): it => {
    v(1em, weak: true)
    // Lists of figures and tables (all level-1 entries) stay in regular weight.
    if it.element.func() == figure {
      // "Figure 1 - Title", as in the caption.
      it.indented(none, [#it.prefix() - #it.inner()])
    } else if it.element.func() == heading and it.element.numbering == "A.1" {
      // Appendix and annex entries read "APPENDIX A - TITLE" (see `appendix`).
      let n = numbering("A", ..counter(heading).at(it.element.location()))
      strong(link(it.element.location(), it.indented(
        none,
        [#upper[#it.element.supplement #n - #it.element.body] #box(width: 1fr, it.fill) #it.page()],
      )))
    } else if it.element.func() == heading and it.element.numbering == none {
      strong(upper(it))
    } else {
      strong(it)
    }
  }

  // References (ABNT NBR 6023): left-aligned, not justified, in the IME-USP
  // author-date style, single spaced inside each entry with one blank line
  // between entries. A `style` passed to `bibliography` overrides it.
  set bibliography(style: read("usp-ime.csl", encoding: none))
  show bibliography: set par(justify: false, leading: 0.5em, spacing: 1.2em)

  // Footnotes (USP Diretrizes 2.2.0, 4.7): 10 pt, single spaced.
  show footnote.entry: set text(size: 10pt)
  show footnote.entry: set par(leading: 0.5em, justify: false)

  // Captions (USP Diretrizes 2.6, 2.7): on top, "Figure 1 - Title", brief,
  // single spaced, 10 pt. The same text appears in the lists of figures/tables.
  show figure: set text(size: 10pt)
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: image): set figure.caption(position: top)
  set figure.caption(separator: " - ")
  show figure.caption: set par(leading: 0.5em, spacing: 0.5em)

  body
}

/// The "Source: ..." line printed under a figure or table (USP Diretrizes 2.6,
/// 2.7): 10 pt, single spaced, left-aligned, with the label in the document
/// language. Put it inside the figure, after the content:
/// `#figure(image("a.png") + figure-source[Author (2026).], caption: [Title])`.
/// - body (content): The source, e.g. `[Elaborated by the author.]`.
/// - label (auto, content or none): The label before the body (auto: "Fonte: "
///   in Portuguese, "Source: " otherwise).
#let figure-source(body, label: auto) = context {
  let label = if label == auto {
    if text.lang == "pt" [Fonte: ] else [Source: ]
  } else { label }
  block(width: 100%, above: 0.8em, below: 0pt, {
    set text(size: 10pt, weight: "regular")
    set par(justify: false, leading: 0.5em)
    set align(left)
    label
    body
  })
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
// "Appendix A", and the level-1 heading printed as "APPENDIX A - TITLE".
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
    counter(footnote).update(0)
    v(1.5cm)
    set text(size: 14pt, weight: "bold", hyphenate: false)
    set par(justify: false)
    align(center, upper[#it.supplement #counter(heading).display("A") - #it.body])
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
