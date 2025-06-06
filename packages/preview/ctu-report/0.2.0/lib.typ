#import "@preview/hydra:0.6.0": hydra
#import "titlepage.typ": *

#let ctu-report(
  doc-category: none,
  doc-title: none,
  author: none,
  affiliation: none,
  language: "cs",
  show-outline: true,
  faculty: "CVUT",
  body,
) = {
  // ----- Global Parameters ------------------------

  set document(title: doc-title, author: author)
  set text(lang: language)

  set math.equation(numbering: "(1)")

  counter(page).update(0) // so TOC after titlepage begins with page no 1 (roman)

  let body-font = "New Computer Modern"
  let body-size = 11pt
  let heading-font = "Technika"
  let info-size = 10pt // heading font is used in this size for kind of "information blocks"
  let label-size = 9pt // heading font is used in this size for different sorts of labels
  let in-outline = state("in-outline", true) // are we inside or outside of the outline (for roman/arabic page numbers)?
  //
  //

  // ----- Title Page ------------------------

  let logo = "logos/"

  let faculties = (
    "CVUT",
    "F1",
    "F2",
    "F3",
    "F4",
    "F5",
    "F6",
    "F7",
    "F8",
    "CIIRC",
    "KU",
    "MUVS",
    "UCEEB",
    "UTEF",
    "UTVS",
  )

  if language == "cs" {
    if faculty in faculties {
      logo += faculty + ".svg"
    } else {
      logo += "CVUT.svg"
    }
  } else {
    if faculty in faculties {
      logo += faculty + "_en.svg"
    } else {
      logo += "CVUT_en.svg"
    }
  }

  titlepage(
    doc-category,
    doc-title,
    author,
    affiliation,
    image(logo, height: 2.3cm),
    heading-font,
    info-size,
  )
  // ----- Basic Text- and Page-Setup ------------------------

  set text(
    font: body-font,
    size: body-size,
  )

  set par(
    justify: true,
    leading: 0.65em,
    spacing: 1.65em,
    first-line-indent: 0em,
  )

  set page(
    paper: "a4",
    // horizontal 1.5cm-grid = 14u: 3u left margin, 9u text, 2u right margin
    //     Idea: one-sided document; if printed on paper, the pages are often bound or stapled
    //     on the left side; so more space needed on the left. On-screen it doesn't matter.
    // vertical 1.5cm-grid ≈ 20u: 2u top margin, 14u text, 2u botttom margin
    //     header with height ≈ 0.6cm is visually part of text block --> top margin = 3cm + 0.6cm
    margin: (top: 3.6cm, left: 4.5cm, right: 3cm, bottom: 3cm),
    // the header shows the main chapter heading  on the left and the page number on the right
    header: grid(
      columns: (1fr, 1fr),
      align: (left, right),
      row-gutter: 0.5em,
      text(font: heading-font, size: label-size, context { hydra(1, use-last: true, skip-starting: false) }),
      text(
        font: heading-font,
        size: label-size,
        number-type: "lining",
        context {
          if in-outline.get() {
            counter(page).display("i") // roman page numbers for the TOC
          } else {
            counter(page).display("1") // arabic page numbers for the rest of the document
          }
        },
      ),
      grid.cell(colspan: 2, line(length: 100%, stroke: 0.5pt)),
    ),
    header-ascent: 1.5em,
  )

  // ----- Numbering Schemes ------------------------

  set heading(numbering: "1.")
  show heading: it => {
    set text(font: heading-font, fill: blue, weight: "regular")
    block(
      it,
      height: 1 * body-size,
      above: 2 * body-size,
      below: 1 * body-size,
      sticky: true,
    )
  }

  set figure(numbering: "1")
  show figure.caption: it => {
    set text(font: heading-font, size: label-size)
    block(it)
  }

  // ----- Table of Contents ------------------------

  // to detect, if inside or outside the outline (for different page numbers)
  show outline: it => {
    in-outline.update(true)
    it
    in-outline.update(false)
  }

  // top-level TOC entries in bold without filling
  show outline.entry.where(level: 1): it => {
    set block(above: 2 * body-size)
    set text(font: heading-font, weight: "bold", size: info-size)
    link(
      it.element.location(), // make entry linkable
      it.indented(it.prefix(), it.body() + box(width: 1fr) + it.page()),
    )
  }

  // other TOC entries in regular with adapted filling
  show outline.entry.where(level: 2).or(outline.entry.where(level: 3)): it => {
    set block(above: body-size)
    set text(font: heading-font, size: info-size)
    link(
      it.element.location(), // make entry linkable
      it.indented(
        it.prefix(),
        it.body() + "  " + box(width: 1fr, repeat([.], gap: 2pt)) + "  " + it.page(),
      ),
    )
  }

  if show-outline {
    outline(
      title: if language == "cs" {
        "Obsah"
      } else {
        "Contents"
      },
      indent: auto,
    )
    counter(page).update(0) // so the first chapter starts at page 1 (now in arabic numbers)
  } else {
    in-outline.update(false) // even if outline is not shown, we want to continue with arabic page numbers
    counter(page).update(1)
  }

  pagebreak()

  // ----- Body Text ------------------------

  body
}
