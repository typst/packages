// vlb.typ
//
// VLB/D93 bibliographic page for publication in the IWS Mitteilungshefte.
// Text and layout follow the current Hefte, checked against Hefte 286 to
// 319 on elib, which all share this page word for word. "D93" is the
// dissertation location code for the Universität Stuttgart.
//
// In the printed Heft the page order is cover, blank, title page, blank,
// series title page, VLB page. The cover and the series title page come
// from the institute's separate Word template, which keeps the Heft
// numbers consecutive. This module therefore leaves a blank verso after
// the title page and a blank recto where the series title page goes,
// then sets the VLB page on the verso behind it.

#import "common.typ": fonts

#let vlb-page(
  title: [],
  author: "",
  institute: "",
  year: "",
  series: auto,
  heft: "",
  isbn: "",
  printer: "",
  author-sort: auto,
  publisher: auto,
  paper: "a4",
) = {
  let is-a5 = paper == "a5"
  set page(
    paper: paper,
    margin: if is-a5 { (x: 18mm, y: 18mm) } else { (x: 25mm, y: 25mm) },
    header: none,
    footer: none,
    numbering: none,
  )
  set text(font: fonts.sans, fill: black, size: if is-a5 { 9pt } else { 11pt })
  set par(justify: false, leading: 0.65em, spacing: 0.65em)

  let resolved-series = if series == auto {
    "Mitteilungen " + institute + ", Universität Stuttgart"
  } else {
    series
  }

  // Catalog heading "Nachname, Vorname". Splits at the last space, so
  // pass author-sort for compound surnames such as "von Neumann, John".
  let resolved-author-sort = if author-sort != auto {
    author-sort
  } else {
    let parts = author.trim().split(" ")
    if parts.len() > 1 {
      parts.last() + ", " + parts.slice(0, -1).join(" ")
    } else {
      author
    }
  }

  // Publisher line in the genitive, "des Instituts für ...". Institutes
  // whose name does not start with "Institut " get a neutral form.
  let resolved-publisher = if publisher != auto {
    publisher
  } else if institute.starts-with("Institut ") {
    "vom Eigenverlag des Instituts " + institute.slice("Institut ".len())
  } else {
    "im Eigenverlag, " + institute
  }

  // Back of the title page, then the place of the series title page.
  // The hidden dot keeps Typst from dropping the otherwise empty pages.
  hide[.]
  pagebreak()
  hide[.]
  pagebreak()

  // D93 mark and title, top of the page.
  grid(
    columns: (auto, 1fr),
    column-gutter: 5mm,
    text(weight: "bold")[D93],
    text(weight: "bold")[#title],
  )

  v(1fr)

  text(weight: "bold")[Bibliografische Information der Deutschen Nationalbibliothek]
  linebreak()
  [Die Deutsche Nationalbibliothek verzeichnet diese Publikation in der Deutschen Nationalbibliografie; detaillierte bibliografische Daten sind im Internet über http://www.d-nb.de abrufbar]

  v(5mm)

  // Catalog entry in a thin frame. Continuation lines of the title entry
  // are indented, as in the Hefte.
  block(stroke: 0.5pt, inset: 2.5mm, width: 100%)[
    #resolved-author-sort:
    #par(hanging-indent: 8mm)[#title, Universität Stuttgart. - Stuttgart: #institute, #year]
    #v(2mm)
    #if heft != "" [(#resolved-series: H. #heft) \ ]
    Zugl.: Stuttgart, Univ., Diss., #year \
    #if isbn != "" [ISBN #isbn \ ]
    NE: #institute \<Stuttgart\>: Mitteilungen
  ]

  v(5mm)

  [Gegen Vervielfältigung und Übersetzung bestehen keine Einwände, es wird lediglich um Quellenangabe gebeten.]

  v(10mm)

  [Herausgegeben #year #resolved-publisher]

  if printer != "" {
    v(6mm)
    [Druck: #printer]
  }
}
