// pzai-expose.typ -- a Typst version of the pzai example from https://github.com/th-nuernberg/pzai-expose
//
// Mirrors:  \documentclass[11pt, DIV=16, parskip=half]{scrartcl}
//
// Usage:
// #import "pzai-expose.typ": pzai-expose
//
// #show: pzai-expose.with(
//   title: [A fancy and very good title],
//   author: [Mulmus Autorus],
//   email: "mulmus.autorus@uni.edu",
//   paper: "a4",
// )
//
// Options (defaults match your LaTeX line):
//   fontsize  11pt      -- 10pt / 11pt / 12pt
//   paper     "a4"
//   lang      "en"
//

#let serif-fonts = ("New Computer Modern", "Latin Modern Roman", "CMU Serif", "Libertinus Serif")
#let sans-fonts = ("New Computer Modern Sans", "Latin Modern Sans", "CMU Sans Serif")

#let universities = (
  HM: "Hochschule München",
  OTH: "Ostbayerische Technische Hochschule Regensburg",
  THN: "Technische Hochschule Nürnberg Georg Simon Ohm",
)

#let pzai-expose(
  title: none,
  subtitle: none,
  author: none,
  date: auto,
  email: none,
  fontsize: 11pt,
  paper: "a4",
  lang: "en",
  heading-numbering: "1.1",
  university: none,
  body,
) = {
  let icon = if university == universities.HM {
    image("images/HM_Logo.svg", height: 1.5em)
  } else if university == universities.OTH {
    image("images/OTH_Logo.svg", height: 1.5em)
  } else if university == universities.THN {
    image("images/OHM_Logo_50.png", height: 1.5em)
  } else {
    none
  }

  // Validate that the input is a valid university option
  // assert(
  //   university in universities.values(),
  //   message: "Invalid university selected. Choose from: universities.HM, universities.OTH, or universities.THN",
  // )

  // --- Typearea (KOMA, oneside, BCOR=0) -------------------------------------
  // Top margin = 1 strip, bottom = 2 strips, side margins = 1.5 strips each.
  // Percentages in page margins are relative to the page dimension.

  set page(
    paper: paper,
    margin: (
      top: 12%,
      bottom: 12%,
      x: 10%,
    ),

    header: [
      #grid(
        columns: (1fr, auto),
        align: (left + horizon, right + horizon),
        icon, text(size: 8.5pt, fill: gray.darken(20%))[#title],
      )
      #v(-4pt)
      #line(length: 100%, stroke: 0.5pt + gray)
    ],
    numbering: "1",
    number-align: center,
  )

  // --- Text and paragraphs ---------------------------------------------------
  set text(font: serif-fonts, size: fontsize, lang: lang)

  show link: it => text(
    // fill: blue.darken(20%),
    font: serif-fonts,
    size: 1.31em,
    it,
  )

  // Typst's par.spacing is the whole gap between paragraphs (it replaces the
  // line leading there), so LaTeX's parskip is added on top of the leading.
  let leading = 0.6em
  let (par-spacing, indent) = (leading + 0.62em, 0pt)
  set par(
    justify: true,
    leading: leading,
    spacing: par-spacing,
    first-line-indent: indent,
  )

  // --- Headings: sans-serif bold, \Large / \large / \normalsize -------------
  set heading(numbering: heading-numbering)
  show heading: it => {
    // let size = if it.level == 1 { 1.31em } else if it.level == 2 { 1.09em } else { 1em }
    let above = if it.level == 1 { 1.8em } else if it.level == 2 { 1.5em } else { 1.3em }
    let below = above * 0.8
    set text(font: sans-fonts, weight: "bold")
    set par(first-line-indent: 0pt, justify: false)
    block(above: above, below: below, sticky: true, {
      if it.numbering != none and it.level <= 3 {
        counter(heading).display(it.numbering)
        h(1em)
      }
      it.body
    })
  }

  // --- Lists, figures, math --------------------------------------------------
  set list(indent: 1em, body-indent: 0.6em)
  set enum(indent: 1em, body-indent: 0.6em)
  set figure.caption(separator: [: ])
  show figure.where(kind: table): set figure.caption(position: top)
  set math.equation(numbering: "(1)")

  // --- Title block (\maketitle) ----------------------------------------------
  if title != none {
    let date-str = if date == auto {
      datetime.today().display("[month repr:long] [day padding:none], [year]")
    } else {
      date
    }

    // let authors = if type(author) == array { author.join(", ") } else { author }
    let email = if type(email) == str {
      let dest = "mailto:" + email
      link(dest, email)
    }

    align(center, block(width: 100%, above: 0pt, below: 2.2em, {
      set par(first-line-indent: 0pt, justify: false)
      text(font: sans-fonts, weight: "bold", size: 1.89em, title)
      if subtitle != none {
        v(0.7em)
        text(font: sans-fonts, weight: "bold", size: 1.31em, subtitle)
      }

      if author != none {
        v(0.5em)
        text(size: 1.31em, author)
      }
      if email != none {
        ", "
        email
      }
      if date-str != none {
        v(0.5em)
        text(size: 1.31em, date-str)
        v(0.7em)
      }
    }))
  }

  body
}
