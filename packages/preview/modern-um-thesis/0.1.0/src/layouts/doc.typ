#import "@preview/cuti:0.3.0": show-cn-fakebold
#import "@preview/hallon:0.1.1" as hallon
#import "@preview/itemize:0.1.2" as el
#import "@preview/numbly:0.1.0": numbly
#import "../utils/convert.typ": *
#import "../utils/numbering.typ": *

/// Document metadata & global settings
///
/// -> content
#let doc(
  /// Type of thesis
  ///
  /// -> "doctor" | "master" | "bachelor"
  doctype: "doctor",
  /// Language of the thesis
  ///
  /// -> "en" | "zh" | "pt"
  lang: "en",
  /// Enable double-sided printing
  ///
  /// -> bool
  double-sided: true,
  /// Add margins to binding side for printing
  ///
  /// -> bool
  print: true,
  /// Thesis information
  ///
  /// -> dictionary
  info: (:),
  /// -> content
  body,
) = {
  set page(margin: if doctype == "doctor" {
    if not print {
      (top: 2.5cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm)
    } else if double-sided {
      (top: 2.5cm, bottom: 2.5cm, inside: 4cm, outside: 2.5cm)
    } else {
      (top: 2.5cm, bottom: 2.5cm, left: 4cm, right: 2.5cm)
    }
  } else if doctype == "master" {
    if not print {
      (top: 1in, bottom: 1in, left: 1in, right: 1in)
    } else if double-sided {
      (top: 1in, bottom: 1in, inside: 1.5in, outside: 1in)
    } else {
      (top: 1in, bottom: 1in, left: 1.5in, right: 1in)
    }
  } else if doctype == "bachelor" {
    if not print {
      (top: 2.5cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm)
    } else if double-sided {
      (top: 2.5cm, bottom: 2.5cm, inside: 4cm, outside: 2.5cm)
    } else {
      (top: 2.5cm, bottom: 2.5cm, left: 4cm, right: 2.5cm)
    }
  })
  set text(
    font: ("Times New Roman", "Pmingliu"),
    size: 12pt,
    lang: lang,
    top-edge: 1em,
    bottom-edge: 0em,
  )
  set par(
    justify: true,
    // 0.17em: single line spacing in MS Word
    // 0.75em: 1.5 line spacing in MS Word
    // 1.33em: double line spacing in MS Word
    leading: if doctype == "doctor" { 1.33em } else { 0.75em },
    spacing: 1.33em,
    // Enable first-line indent for Chinese
    first-line-indent: if lang == "zh" { (amount: 2em, all: true) } else { (amount: 0pt, all: false) },
  )
  // Align first level headings to the center
  show heading.where(level: 1): set align(center)
  // Start a new page at every first level heading
  show heading.where(level: 1): body => {
    pagebreak(weak: true)
    if doctype == "master" {
      upper(body)
    } else {
      body
    }
  }
  // Double-line spacing for headings
  show heading: set block(above: 1.33em, below: 0.75em)
  show heading.where(level: 1): set block(below: 36pt)
  // Change bibliography title to "References"
  set bibliography(title: "References") if doctype == "doctor"

  show: show-cn-fakebold

  ////////////////////////////
  // Custom format settings //
  ////////////////////////////

  // Figure/image settings

  // Apply subfigure styles.
  show: hallon.style-figures.with(heading-levels: 1)
  // Use short supplement for figures and subfigures.
  show figure.where(kind: image): set figure(supplement: [Fig.])
  show figure.where(kind: image): set figure.caption(separator: [. ])
  show figure.where(kind: "subfigure"): set figure(supplement: [Fig.])
  // Figure captions settings
  show figure.caption: set text(weight: "bold")
  // Decrease spacing in figure captions
  show figure.caption: set par(leading: 0.17em, justify: false)
  // Place table and algorithm captions above
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: "algorithm"): set figure.caption(position: top)
  // Allow figures to break across pages
  show figure: set block(breakable: true)
  // Make images sticky to avoid splitting
  show figure.where(kind: image): set block(sticky: true)

  // Table settings

  set table(stroke: none)
  // Decrease spacing in table contents
  show table: set par(leading: 0.17em, spacing: 0.75em)

  // List settings

  // Fix bug when line is too tall
  show ref: el.ref-enum
  show: el.default-enum-list
  // Decrease spacing in table contents
  show footnote.entry: set par(leading: 0.17em, spacing: 0.75em)
  show list: set par(leading: 0.17em)
  show enum: set par(leading: 0.17em)

  set math.equation(number-align: end + bottom, supplement: none)

  // Override ref formatting for chapter/appendix headings
  show ref: it => {
    let el = it.element
    if el == none {
      it
    } else if el.func() == heading and el.level == 1 {
      link(el.location(), numbering(
        numbly(pattern-heading-first-level(lang: lang, supplement: el.supplement)),
        ..counter(heading).at(el.location()),
      ))
    } else {
      it
    }
  }

  // Document metadata
  set document(
    title: info.title-en,
    author: if lang == "zh" {
      to-str(info.author-zh)
    } else if lang == "pt" {
      to-str(info.author-pt)
    } else {
      to-str(info.author-en)
    },
  )

  body
}
