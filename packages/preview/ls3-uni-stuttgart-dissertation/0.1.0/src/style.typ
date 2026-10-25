// style.typ
//
// Page geometry, fonts, headings, and styling rules for
// the dissertation. Used by lib.typ. Not a public-facing module.
//
// The A4 mode follows the Merkblatt manuscript rules: 12pt body, 1.5
// line spacing, margins over 2cm on every side. Its geometry, running
// header, and line spacing match the recent IWS Mitteilungshefte, e.g.
// Hefte 300 and 305 of LS3 and the LH2 Hefte, which print the A4 file
// scaled to A5. The A5 mode is a print layout derived from the diss_a5
// LaTeX template.

#import "common.typ": colors, fonts
#import "@preview/codly:2.0.0" as codly
#import "@preview/codly-languages:0.1.10": codly-languages

// Layout metrics per paper format. Single source of truth for everything
// that differs between the A4 manuscript and the A5 print version.
#let metrics(paper) = {
  if paper == "a5" {
    (
      paper: "a5",
      margin: (inside: 22mm, outside: 17mm, top: 26mm, bottom: 24mm),
      header-ascent: 6mm,
      body-size: 10pt,
      leading: 0.8em,
      par-spacing: 1.2em,
      h1-size: 18pt,
      h2-size: 12pt,
      h3-size: 11pt,
      h4-size: 10pt,
      h1-above: 1.2cm,
      h1-below: 1cm,
      h2-below: 4mm,
      corner-size: 9pt,
    )
  } else {
    (
      paper: "a4",
      // 156mm text block with 26mm inside and 28mm outside, body text
      // from 39mm, header line at about 24mm, as in the IWS Hefte.
      margin: (inside: 26mm, outside: 28mm, top: 39mm, bottom: 42mm),
      header-ascent: 10mm,
      body-size: 12pt,
      // Merkblatt asks for 1.5 line spacing in the manuscript. 0.8em with
      // 12pt body gives the 17.9pt baseline pitch of LaTeX's onehalf
      // spacing measured in the Hefte.
      leading: 0.8em,
      par-spacing: 1.4em,
      // LaTeX \huge, \Large, and \large at 12pt, as in the Hefte.
      h1-size: 24pt,
      h2-size: 17.28pt,
      h3-size: 14.4pt,
      h4-size: 12pt,
      h1-above: 2.4cm,
      h1-below: 1.2cm,
      h2-below: 7mm,
      corner-size: 11pt,
    )
  }
}

// Running header as in the IWS Hefte. Page number in the outer corner,
// the current section on recto pages and the current chapter on verso
// pages centered, a thin rule below. No header on chapter opening pages
// and on blank pages before a chapter. Front-matter chapter pages show
// their Roman number at the bottom outer corner, main-matter chapter
// pages show none, both as in the Hefte.
//
// Blank pages are found through <ls3-chapter-end> markers, which the
// chapter heading rule places at the end of the previous content. A page
// right before a chapter page is blank if that content ended earlier.
#let _heading-text(hd) = {
  if hd.numbering == none { return hd.body }
  let nums = counter(heading).at(hd.location())
  [#numbering(hd.numbering, ..nums)#h(0.6em)#hd.body]
}

#let two-sided-header-footer(language: "english", corner-size: 11pt) = {
  let header-content = context {
    let p = here().page()
    if page.numbering == none { return }
    let chapters = query(heading.where(level: 1))
    if chapters.any(c => c.location().page() == p) { return }
    let next = chapters.find(c => c.location().page() == p + 1)
    if next != none {
      let ends = query(selector(<ls3-chapter-end>).before(next.location()))
        .filter(m => m.location().page() < p + 1)
      if ends.len() > 0 and ends.last().location().page() < p { return }
    }
    let previous = chapters.filter(c => c.location().page() <= p)
    if previous.len() == 0 { return }
    let chapter = previous.last()
    let title = _heading-text(chapter)
    if calc.odd(p) {
      let sections = query(selector(heading.where(level: 2)).after(chapter.location()))
        .filter(s => s.location().page() <= p)
      if sections.len() > 0 { title = _heading-text(sections.last()) }
    }
    let number = counter(page).display(page.numbering)
    set text(size: corner-size)
    set par(justify: false)
    block(width: 100%, stroke: (bottom: 0.4pt), inset: (bottom: 1.5mm))[
      #grid(
        columns: (1fr, auto, 1fr),
        align: (left, center, right),
        if calc.odd(p) { [] } else { number },
        title,
        if calc.odd(p) { number } else { [] },
      )
    ]
  }

  let footer-content = context {
    let p = here().page()
    if page.numbering != "I" { return }
    if not query(heading.where(level: 1)).any(c => c.location().page() == p) { return }
    set text(size: corner-size)
    align(if calc.odd(p) { right } else { left }, counter(page).display(page.numbering))
  }

  (header: header-content, footer: footer-content)
}

// Apply all global dissertation styling. body-font is "sans" (default,
// TeX Gyre Heros throughout) or "serif" (New Computer Modern body with
// sans headings, as in most IWS Hefte).
// heading-rule draws a thin mittelblau rule below every chapter-level heading.
#let apply-style(body, paper: "a4", body-font: "sans", heading-rule: false) = {
  let m = metrics(paper)

  set page(
    paper: m.paper,
    margin: m.margin,
    binding: left,
    header-ascent: m.header-ascent,
  )

  // New Computer Modern ships with Typst. The shared serif stack also
  // names Latin Modern Roman, which warns on every build where it is not
  // installed.
  let body-font-stack = if body-font == "serif" { "New Computer Modern" } else { fonts.sans }
  set text(font: body-font-stack, size: m.body-size)
  show heading: set text(font: fonts.sans)
  set par(leading: m.leading, justify: true, first-line-indent: 0pt, spacing: m.par-spacing)

  set enum(indent: 1em)
  set list(indent: 1em)
  set terms(indent: 1em)

  // Running header with the page number, footer only on front-matter
  // chapter pages.
  let hf = two-sided-header-footer(corner-size: m.corner-size)
  set page(header: hf.header, footer: hf.footer)

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

  // Chapter-level heading. New right-opening page, number inline, optional
  // thin mittelblau rule below. The spacing to the text is the same with
  // and without the rule.
  show heading.where(level: 1): it => {
    // Marks where the previous content ended, see the header.
    [#metadata(none) <ls3-chapter-end>]
    pagebreak(to: "odd", weak: true)
    v(m.h1-above)
    let prefix = if it.numbering != none {
      [#counter(heading).display(it.numbering)#h(0.6em)]
    } else {
      []
    }
    set par(justify: false)
    text(
      size: m.h1-size,
      weight: "bold",
      fill: black,
      hyphenate: false,
    )[#prefix#it.body]
    v(4mm)
    if heading-rule {
      line(length: 100%, stroke: 1pt + colors.mittelblau)
    }
    v(m.h1-below)
  }

  show heading.where(level: 2): it => {
    v(8mm, weak: true)
    text(size: m.h2-size, weight: "bold", fill: black, it)
    v(m.h2-below)
  }
  show heading.where(level: 3): it => {
    v(5mm, weak: true)
    text(size: m.h3-size, weight: "bold", fill: black, it)
    v(1mm)
  }
  show heading.where(level: 4): it => {
    v(3mm, weak: true)
    text(size: m.h4-size, weight: "bold", style: "italic", fill: black, it)
  }

  show figure.caption: it => {
    text(weight: "bold", fill: black, it.supplement + " " + str(it.counter.display()) + ":")
    " "
    it.body
  }

  body
}
