// ══════════════════════════════════════════════════════
// BASE STYLE
// ══════════════════════════════════════════════════════

#import "@preview/wordometer:0.1.5": word-count as _word-count, total-words as totalwords
#import "@preview/itemize:0.2.0" as itmz

#let word-count = _word-count
#let total-words = totalwords

// custom citations
#let bib = bibliography.with(style: "chicago-author-date")

// Fancy code-block styling (codly) lives in the `utilst` package:
//   #import "@preview/utilst:0.1.0": code-style
//   #show: code-style

#let base-style(body) = {
  show: _word-count
  show: itmz.default-enum-list.with(indent: auto, item-spacing: auto)
  show grid: it => {
    set image(width: auto)
    it
  }

  // Centered "current/total" page number in the footer of every page.
  set page(numbering: "1/1", number-align: center)
  set text(font: "New Computer Modern", size: 12pt)
  set heading(numbering: "1.1")
  set enum(numbering: "1.", full: true)
  set math.equation(numbering: none)
  set math.mat(delim: "[", gap: 0.3em)
  // 1.5 line spacing.
  set par(justify: true, leading: 0.65em)
  set image(width: 30em)
  body
}

#let page-setup(body) = {
  set page(paper: "a4", margin: (left: 3cm, right: 3cm, top: 2cm, bottom: 2cm))
  base-style(body)
}
