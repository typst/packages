#import "@preview/codelst:2.0.2": *
#import "@preview/hydra:0.6.0": hydra
#import "acronym-lib.typ": init-acronyms, print-acronyms, acr, acrpl, acrs, acrspl, acrl, acrlpl, acrf, acrfpl
#import "glossary-lib.typ": init-glossary, print-glossary, gls
#import "locale.typ": TABLE_OF_CONTENTS, APPENDIX, REFERENCES
#import "titlepage.typ": *
#import "confidentiality-statement.typ": *
#import "declaration-of-authorship.typ": *
#import "check-attributes.typ": *

// Workaround for the lack of an `std` scope.
#let std-bibliography = bibliography

#let clean-dhbw(
  title: none,
  authors: (:),
  language: none,
  at-university: none,
  confidentiality-marker: (display: false),
  type-of-thesis: none,
  show-confidentiality-statement: true,
  show-declaration-of-authorship: true,
  show-table-of-contents: true,
  show-acronyms: true,
  show-abstract: true,
  acronym-spacing: 5em,
  glossary-spacing: 1.5em,
  abstract: none,
  appendix: none,
  acronyms: none,
  glossary: none,
  confidentiality-statement-content: none,
  declaration-of-authorship-content: none,
  titlepage-content: none,
  university: none,
  university-location: none,
  university-short: none,
  city: none,
  supervisor: (:),
  date: none,
  date-format: "[day].[month].[year]",
  bibliography: none,
  bib-style: "ieee",
  math-numbering: "(1)",
  logo-left: image("dhbw.svg"),
  logo-right: none,
  ignored-link-label-keys-for-highlighting: (),
  body,
) = {
  // check required attributes
  check-attributes(
    title,
    authors,
    language,
    at-university,
    confidentiality-marker,
    type-of-thesis,
    show-confidentiality-statement,
    show-declaration-of-authorship,
    show-table-of-contents,
    show-acronyms,
    show-abstract,
    acronym-spacing,
    glossary-spacing,
    abstract,
    appendix,
    acronyms,
    university,
    university-location,
    supervisor,
    date,
    city,
    bibliography,
    bib-style,
    logo-left,
    logo-right,
    university-short,
    math-numbering,
    ignored-link-label-keys-for-highlighting,
  )

  // ---------- Fonts & Related Measures ---------------------------------------

  let body-font = "Source Serif 4"
  let body-size = 11pt
  let heading-font = "Source Sans 3"
  let h1-size = 40pt
  let h2-size = 16pt
  let h3-size = 11pt
  let h4-size = 11pt
  let page-grid = 16pt  // vertical spacing on all pages

  
  // ---------- Basic Document Settings ---------------------------------------

  set document(title: title, author: authors.map(author => author.name))
  let many-authors = authors.len() > 3
  let in-frontmatter = state("in-frontmatter", true)    // to control page number format in frontmatter
  let in-body = state("in-body", true)                 // to control heading formatting in/outside of body

  init-acronyms(acronyms)
  init-glossary(glossary)

  // customize look of figure
  set figure.caption(separator: [ --- ], position: bottom)

  // math numbering
  set math.equation(numbering: math-numbering)

  // set link style for links that are not acronyms
  let acronym-keys = if (acronyms != none) {
    acronyms.keys().map(acr => ("acronyms-" + acr))
  } else {
    ()
  }

  let glossary-keys = if (glossary != none) {
    glossary.keys().map(gls => ("glossary-" + gls))
  } else {
    ()
  }

  // show link: it => if (str(it.dest) not in (acronym-keys + glossary-keys + ignored-link-label-keys-for-highlighting)) {
  //   text(fill: blue, it)
  // } else {
  //   it
  // }

  // ========== TITLEPAGE ========================================

  if (titlepage-content != none) {
    titlepage-content
  } else {
    titlepage(
      authors,
      date,
      heading-font,
      language,
      logo-left,
      logo-right,
      many-authors,
      supervisor,
      title,
      type-of-thesis,
      university,
      university-location,
      at-university,
      date-format,
      show-confidentiality-statement,
      confidentiality-marker,
      university-short,
      page-grid,
    )
  }
  counter(page).update(1)  

  // ---------- Page Setup ---------------------------------------

  // adapt body text layout to basic measures
  set text(
    font: body-font, 
    lang: language, 
    size: body-size - 0.5pt,      // 0.5pt adjustment because of large x-hight
    top-edge: 0.75 * body-size, 
    bottom-edge: -0.25 * body-size,
  )
  set par(
    spacing: page-grid,
    leading: page-grid - body-size, 
    justify: true,
  )

  set page(
    margin: (top: 4cm, bottom: 3cm, left: 4cm, right: 3cm),
    header:
      grid(
        columns: (1fr, 1fr),
        align: (left, right),
        row-gutter: 0.5em,
        smallcaps(text(font: heading-font, size: body-size, 
          context {
            hydra(1, display: (_, it) => it.body, use-last: true, skip-starting: false)
          },
        )),
        text(font: heading-font, size: body-size, 
          number-type: "lining",
          context {if in-frontmatter.get() {
              counter(page).display("i")      // roman page numbers for the frontmatter
            } else {
              counter(page).display("1")      // arabic page numbers for the rest of the document
            }
          }
        ),
        grid.cell(colspan: 2, line(length: 100%, stroke: 0.5pt)),
      ),
      header-ascent: page-grid,
  )


  // ========== FRONTMATTER ========================================
  
  // ---------- Heading Format (Part I) ---------------------------------------

  show heading: set text(weight: "bold", fill: luma(80), font: heading-font)
  show heading.where(level: 1): it => {v(2 * page-grid) + text(size: 2 * page-grid, it)}

  // ---------- Abstract ---------------------------------------

  if (show-abstract and abstract != none) {
    heading(level: 1, numbering: none, outlined: false, ABSTRACT.at(language))
    text(abstract)
    pagebreak()
  }

  // ---------- ToC (Outline) ---------------------------------------

  // top-level TOC entries in bold without filling
  show outline.entry.where(level: 1): it => {
    set block(above: page-grid)
    set text(font: heading-font, weight: "semibold", size: body-size)
    link(
      it.element.location(),    // make entry linkable
      it.indented(it.prefix(), it.body() + box(width: 1fr,) +  it.page())
    )
  }

  // other TOC entries in regular with adapted filling
  show outline.entry.where(level: 2).or(outline.entry.where(level: 3)): it => {
    set block(above: page-grid - body-size)
    set text(font: heading-font, size: body-size)
    link(
      it.element.location(),  // make entry linkable
      it.indented(
          it.prefix(),
          it.body() + "  " +
            box(width: 1fr, repeat([.], gap: 2pt), baseline: 30%) +
            "  " + it.page()
      )
    )
  }

  if (show-table-of-contents) {
    outline(
      title: TABLE_OF_CONTENTS.at(language),
      indent: auto,
      depth: 3,
    )
  }

  in-frontmatter.update(false)  // end of frontmatter
  counter(page).update(0)       // so the first chapter starts at page 1 (now in arabic numbers)

  // ========== DOCUMENT BODY ========================================

 // ---------- Heading Format (Part II: H1-H4) ---------------------------------------

  set heading(numbering: "1.1.1")

  show heading: it => {
    set par(leading: 4pt, justify: false)
    text(it, top-edge: 0.75em, bottom-edge: -0.25em)
    v(page-grid, weak: true)
  }

  show heading.where(level: 1): it => {
    set par(leading: 0pt, justify: false)
    pagebreak()
    context{ 
      if in-body.get() {
        v(page-grid * 10)
        place(              // place heading number prominently at the upper right corner
          top + right,
          dx: 9pt,          // slight adjustment for optimal alignment with right margin
          text(counter(heading).display(), 
            top-edge: "bounds",
            size: page-grid * 10, weight: 900, luma(235), 
          )
        )
        text(               // heading text on separate line
          it.body, size: h1-size,
          top-edge: 0.75em, 
          bottom-edge: -0.25em,
        )
      } else {
        v(2 * page-grid) 
        text(size: 2 * page-grid, counter(heading).display() + h(0.5em) + it.body)   // appendix
      }
    }
  }

  show heading.where(level: 2): it => {v(16pt) + text(size: h2-size, it)}
  show heading.where(level: 3): it => {v(16pt) + text(size: h3-size, it)}
  show heading.where(level: 4): it => {v(16pt) + smallcaps(text(size: h4-size, weight: "semibold", it.body))}

 // ---------- Body Text ---------------------------------------

  body


  // ========== APPENDIX ========================================

  in-body.update(false)
  set heading(numbering: "A.1")
  counter(heading).update(0)

  // ---------- Bibliography ---------------------------------------

  show std-bibliography: set heading(numbering: "A.1")
  if bibliography != none {
    set std-bibliography(
      title: REFERENCES.at(language),
      style: bib-style,
    )
    bibliography
  }

  // ---------- Acronyms & Glossary ---------------------------------------

  if (show-acronyms and acronyms != none and acronyms.len() > 0) {
    print-acronyms(language, acronym-spacing)
  }

  if (glossary != none and glossary.len() > 0) {
    print-glossary(language, glossary-spacing)
  }

  // ---------- Appendix (other contents) ---------------------------------------

  if (appendix != none) {       // the user has to provide heading(s)
    appendix
  }

  // ========== LEGAL BACKMATTER ========================================

  set heading(numbering: it => h(-18pt) + "", outlined: false)

  // ---------- Confidentiality Statement ---------------------------------------

  if (not at-university and show-confidentiality-statement) {
    confidentiality-statement(
      authors,
      title,
      confidentiality-statement-content,
      university,
      university-location,
      date,
      language,
      many-authors,
      date-format,
    )
  }

  // ---------- Declaration Of Authorship ---------------------------------------

  if (show-declaration-of-authorship) {
    declaration-of-authorship(
      authors,
      title,
      declaration-of-authorship-content,
      date,
      language,
      many-authors,
      at-university,
      city,
      date-format,
    )
  }

}
