#import "@preview/hydra:0.6.2": hydra
#import "titlepage.typ": *

// ----- Main Template Function: `basic-report` ----------------------

#let basic-report(
  doc-category: none,
  doc-title: none,
  author: none,
  affiliation: none,
  logo: none,
  language: "de",
  show-outline: true,
  compact-mode: false,
  heading-color: blue,
  heading-font: "Ubuntu", // recommended alternatives: "Fira Sans", "Lato", "Source Sans Pro"
  body,
) = {

  // ----- Global Parameters ------------------------

  set document(title: doc-title, author: author)
  set text(lang: language)


  let body-font = "Vollkorn"
  let body-size = 11pt
  // let heading-font = "Ubuntu"

  // heading font is used in this size for kind of "information blocks"
  let info-size = 10pt              
  
  // heading font is used in this size for different sorts of labels            
  let label-size = 9pt                          
  
  // are we inside or outside of the outline (for roman/arabic page numbers)?
  let in-outline = state("in-outline", if compact-mode {false} else {true})    

  // ----- Title Page ------------------------

  if (not compact-mode) {
    counter(page).update(0)                     // so TOC after titlepage begins with page no 1 (roman)
    titlepage(
      doc-category,
      doc-title,
      author,
      affiliation,
      logo,
      heading-font,
      heading-color,
      info-size,
    )
  } 

  // ----- Basic Text- and Page-Setup ------------------------

  set text(
    font: body-font,
    size: body-size,
    // Vollkorn has a broader stroke than other fonts; in order to adapt the grey value (Grauwert)
    // of the page the font gets printed in a dark grey (instead of completely black)
    fill: luma(50)
  )

  set par(
    justify: true,
    leading: 0.75em,
    spacing: 1.65em,
    first-line-indent: 0em,
  )

  // Page Grid:
  // Horizontal 1.5cm-grid = 14u: 3u left margin, 9u text, 2u right margin
  //     Idea: one-sided document; if printed on paper, the pages are often bound or stapled
  //     on the left side; so more space needed on the left. On-screen it doesn't matter.
  // Vertical 1.5cm-grid ≈ 20u: 2u top margin, 14u text, 2u botttom margin
  //     header with height ≈ 0.6cm is visually part of text block --> top margin = 3cm + 0.6cm
  set page(               // standard page with header
    paper: "a4",
    margin: (top: 3.6cm, left: 4.5cm, right: 3cm, bottom: 3cm),
    // the header shows the main chapter heading on the left and the page number on the right
    header: context {
      if compact-mode and (counter(page).get().first() == 1) {
        none
      } else {
        grid(
          columns: (1fr, 1fr),
          align: (left, right),
          row-gutter: 0.5em,
          text(font: heading-font, size: label-size,
            context {hydra(1, use-last: false, skip-starting: false)},),
          text(font: heading-font, size: label-size, 
            number-type: "lining",
            context {if in-outline.get() {
                counter(page).display("i")      // roman page numbers for the TOC
              } else {
                counter(page).display("1")      // arabic page numbers for the rest of the document
              }
            }
          ),
          grid.cell(colspan: 2, line(length: 100%, stroke: 0.5pt)),
        )
      }
    },
    header-ascent: 1.5em
  )

  
  // ----- Headings & Numbering Schemes ------------------------

  set heading(numbering: "1.")
  show heading: set text(font: heading-font, fill: heading-color, 
      weight: if compact-mode {"bold"} else {"regular"})
  show heading: set par(justify: false)


  show heading.where(level: 1): it => {
    v(3.8 * body-size, weak: true) + text(it) + v(0.2 * body-size)
  }
  show heading.where(level: 2): it => {
    v(0.8 * body-size) + text(it) + v(0.2 * body-size)
  }
  show heading.where(level: 3): it => {
    v(0.8 * body-size) + text(it) + v(0.2 * body-size)
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
      it.element.location(),    // make entry linkable
      it.indented(it.prefix(), it.body() + box(width: 1fr,) +  strong(it.page()))
    )
  }

  // other TOC entries in regular with adapted filling
  show outline.entry.where(level: 2).or(outline.entry.where(level: 3)): it => {
    set block(above: 0.8 * body-size)
    set text(font: heading-font, size: info-size)
    link(
      it.element.location(),  // make entry linkable
      it.indented(
          it.prefix(),
          it.body() + "  " +
            box(width: 1fr, repeat([.], gap: 2pt)) +
            "  " + it.page()
      )
    )
  }

  if (show-outline and not compact-mode) {
    outline(
      title: if language == "de" { 
        "Inhalt"
      } else if language == "fr" {
        "Table des matières"
      } else if language == "es" {
        "Contenido"
      } else if language == "it" {
        "Indice"
      } else if language == "nl" {
        "Inhoud"
      } else if language == "pt" {
        "Índice"
      } else if language == "zh" {
        "目录"
      } else if language == "ja" {
        "目次"
      } else if language == "ru" {
        "Содержание"
      } else if language == "ar" {
        "المحتويات"
      } else {
        "Contents"
      },
      indent: auto,
    )
    counter(page).update(0)     // so the first chapter starts at page 1 (now in arabic numbers)
  } else {
    in-outline.update(false)    // even if outline is not shown, we want to continue with arabic page numbers
    counter(page).update(1)
  }

  if (not compact-mode) {
    pagebreak()
  }

  // ----- Body Text ------------------------
  
  if compact-mode {             // compact title infos in compact-mode
    compact-title(
      doc-category,
      doc-title,
      author,
      affiliation,
      logo,
      heading-font,             
      heading-color,            
      info-size,                
      body-size,
      label-size,
    )
  }

  body

}
