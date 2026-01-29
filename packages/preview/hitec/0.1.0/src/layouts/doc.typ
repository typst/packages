#import "@preview/itemize:0.2.0" as el
#import "@preview/marginalia:0.3.1" as marginalia: wideblock
#import "../utils/convert.typ": to-str

/// Document metadata & global settings
///
/// -> content
#let doc(
  /// Title of the report
  ///
  /// -> content | string
  title: [],
  /// Name(s) of Author(s)
  ///
  /// -> string | array
  author: "",
  /// Name of Company/Institution
  ///
  /// -> content | string
  company: [],
  /// Confidentiality Level
  ///
  /// -> content | string
  confidential: [],
  /// Date of submission
  ///
  /// -> datetime
  date: datetime.today(),
  /// Enable double-sided printing
  ///
  /// -> bool
  double-sided: true,
  /// Add margins to binding side for printing
  ///
  /// -> bool
  print: true,
  /// -> content
  body,
) = {
  show: marginalia.setup.with(
    inner: if print { (far: 25mm, width: 77.5pt, sep: 5mm) } else { (far: 5mm, width: 15mm, sep: 5mm) },
    outer: (far: 5mm, width: 15mm, sep: 5mm),
    book: double-sided,
  )

  let header-block = context {
    // Omit header at first page
    if counter(page).get().first() == 1 { none } else {
      grid(
        columns: (1fr, auto, 1fr),
        align: (left, center, right),
        to-str(author), confidential, company,
      )
      v(0.17em)
      line(length: 100%)
    }
  }

  let footer-block = context {
    if counter(page).get().first() == 1 { none } else {
      line(length: 100%)
      emph(title) + h(1fr) + counter(page).display()
    }
  }

  set page(
    numbering: "1",
    header: if print {
      wideblock(side: "inner", header-block)
    } else {
      header-block
    },
    // Omit footer at first page
    footer: if print {
      wideblock(side: "inner", footer-block)
    } else {
      footer-block
    },
  )
  counter(page).update(1)

  set text(
    font: "TeX Gyre Heros",
    size: 10pt,
    top-edge: 1em,
    bottom-edge: 0em,
  )
  set par(
    justify: true,
    // 0.17em: single line spacing in MS Word
    // 0.75em: 1.5 line spacing in MS Word
    // 1.33em: double line spacing in MS Word
    leading: 0.17em,
    spacing: 0.17em,
    first-line-indent: (amount: 1.5em, all: true),
  )

  set heading(numbering: "1.1")
  // Ignore binding margin for headings
  show heading: it => if print { wideblock(side: "inner", it) } else { it }
  // Double-line spacing for headings
  show heading: set block(above: 1.33em, below: 0.75em)

  ////////////////////////////
  // Custom format settings //
  ////////////////////////////

  // Figure/image settings

  // Figure captions settings
  show figure.caption: set text(weight: "bold")
  // Place table and algorithm captions above
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: "algorithm"): set figure.caption(position: top)
  // Allow figures to break across pages
  show figure: set block(breakable: true)
  // Make images sticky to avoid splitting
  show figure.where(kind: image): set block(sticky: true)

  // Table settings
  set table(stroke: none)

  // List settings

  // Fix bug when line is too tall
  show ref: el.ref-enum
  show: el.default-enum-list

  // Document metadata
  set document(
    title: title,
    author: author,
    date: date,
  )

  body
}
