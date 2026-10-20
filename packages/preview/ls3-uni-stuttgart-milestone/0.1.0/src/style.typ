// style.typ
//
// Page geometry, fonts, headings, and styling rules for the milestone report.
// Used by lib.typ. Not a public-facing module.

#import "common.typ": colors, fonts
#import "@preview/codly:2.0.0" as codly
#import "@preview/codly-languages:0.1.10": codly-languages

// Two-sided footer with outer-corner page numbers. Pages whose numbering
// pattern is none (title page) emit no footer content.
#let two-sided-footer() = {
  context {
    if page.numbering == none {
      return
    }
    set text(size: 9pt, fill: colors.anthrazit)
    let counter-val = counter(page).get().first()
    let formatted = numbering(page.numbering, counter-val)
    if calc.odd(here().page()) {
      align(right, formatted)
    } else {
      align(left, formatted)
    }
  }
}

// Apply all global styling. Returns content wrapped with the right
// set/show rules. body-font is "sans" (default, Helvetica everywhere) or
// "serif" (New Computer Modern body with sans headings). heading-rule draws a
// thin mittelblau rule below every chapter-level heading.
#let apply-style(body, body-font: "sans", heading-rule: false) = {
  set page(
    paper: "a4",
    margin: (inside: 30mm, outside: 25mm, top: 25mm, bottom: 30mm),
    binding: left,
  )

  // New Computer Modern ships with Typst. The shared serif stack also
  // names Latin Modern Roman, which warns on every build where it is not
  // installed.
  let body-font-stack = if body-font == "serif" { "New Computer Modern" } else { fonts.sans }
  set text(font: body-font-stack, size: 11pt)
  show heading: set text(font: fonts.sans)
  set par(leading: 0.8em, justify: true, first-line-indent: 0pt, spacing: 1.2em)

  set enum(indent: 1em)
  set list(indent: 1em)
  set terms(indent: 1em)

  // Reset the title-page background so the Uni Stuttgart logo does not
  // bleed onto body pages.
  set page(header: none, footer: two-sided-footer(), background: none)

  set heading(numbering: (..nums) => nums.pos().map(str).join("."))

  set math.equation(numbering: "(1)")

  show link: set text(fill: colors.mittelblau)

  show raw.where(block: false): it => box(
    fill: colors.block-body,
    inset: (x: 3pt, y: 0.5pt),
    outset: (y: 1pt),
    radius: 2pt,
    text(font: fonts.mono, size: 0.92em, fill: colors.mittelblau, it),
  )

  show: codly.lang-set_(languages: codly-languages)
  show raw.where(block: true): codly.new

  // Chapter (level 1) heading. New page (any side, NOT forced to odd) with
  // the chapter number rendered inline next to the title in black,
  // optionally followed by a thin mittelblau rule. The spacing to the text
  // is the same with and without the rule. Differs from the thesis on the pagebreak
  // mode: thesis uses `to: "odd"`, milestone does not.
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(2cm)
    let prefix = if it.numbering != none {
      [#counter(heading).display()#h(0.6em)]
    } else {
      []
    }
    set par(justify: false)
    text(
      size: 24pt,
      weight: "bold",
      fill: black,
      hyphenate: false,
    )[#prefix#it.body]
    v(4mm)
    if heading-rule {
      line(length: 100%, stroke: 1pt + colors.mittelblau)
    }
    v(1.5cm)
  }

  show heading.where(level: 2): it => {
    v(8mm, weak: true)
    text(size: 14pt, weight: "bold", fill: black, it)
    v(2mm)
  }
  show heading.where(level: 3): it => {
    v(5mm, weak: true)
    text(size: 12pt, weight: "bold", fill: black, it)
    v(1mm)
  }
  show heading.where(level: 4): it => {
    v(3mm, weak: true)
    text(size: 11pt, weight: "bold", style: "italic", fill: black, it)
  }

  show figure.caption: it => {
    text(weight: "bold", fill: black, it.supplement + " " + str(it.counter.display()) + ":")
    " "
    it.body
  }

  body
}
