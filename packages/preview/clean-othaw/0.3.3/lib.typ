#import "@preview/codelst:2.0.2": *
#import "@preview/hydra:0.6.2": hydra
#import "@preview/glossarium:0.5.10": make-glossary, register-glossary, print-glossary, gls, glspl
#import "locale.typ": TABLE_OF_CONTENTS, APPENDIX, REFERENCES
#import "titlepage.typ": *
#import "check-attributes.typ": *
#import "formalities.typ": *
// Workaround for the lack of an `std` scope.
#let std-bibliography = bibliography

#let clean-othaw(
  title: none,
  authors: (:),
  language: none,
  at-university: none,
  confidentiality-marker: (display: false),
  type-of-thesis: none,
  course-of-studies: none,
  show-confidentiality-statement: true,
  show-declaration-of-authorship: true,
  show-table-of-contents: true,
  show-abstract: true,
  abstract-text: none,
  abstract-content: none,
  keywords: none,
  appendix: none,
  confidentiality-statement-content: none,
  declaration-of-authorship-content: none,
  titlepage-content: none,
  formalities-in-frontmatter: true,
  university: none,
  university-location: none,
  university-short: none,
  city: none,
  faculty: none,
  supervisor: (:),
  date: none,
  date-format: "[day].[month].[year]",
  bibliography: none,
  glossary: none,
  bib-style: "ieee",
  math-numbering: "(1)",
  logo-left: image("oth.svg"),
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
    show-abstract,
    abstract-text,
    appendix,
    university,
    university-location,
    supervisor,
    date,
    city,
    bibliography,
    glossary,
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
  let in-body = state("in-body", true)                  // to control heading formatting in/outside of body

  // customize look of figure
  set figure.caption(separator: [ --- ], position: bottom)

  // math numbering
  set math.equation(numbering: math-numbering)

  // initialize `glossarium`
  // CAVEAT: all `figure` show rules must come before this (see `glossarium` docs)
  show: make-glossary

  // register the glossary passed in `glossary`
  if (glossary != none) {
    register-glossary(glossary)
  }

  // show links in dark blue
  show link: set text(fill: blue.darken(40%))

  // ========== TITLEPAGE ========================================
  if (formalities-in-frontmatter){
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
        faculty,
        at-university,
        date-format,
        show-confidentiality-statement,
        confidentiality-marker,
        university-short,
        page-grid,
        true,
      )
    }
    counter(page).update(1)
    pagebreak(to:"odd")
  }
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
        faculty,
        at-university,
        date-format,
        show-confidentiality-statement,
        confidentiality-marker,
        university-short,
        page-grid,
        false,
      )
    }

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
    margin: (top: 1.5cm, bottom: 1.5cm, left: 2.5cm, right: 2.5cm),
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
  show heading.where(level: 1): it => {v(2 * page-grid) + text(size: 1.8 * page-grid, it)}

  if (formalities-in-frontmatter){
    formalities(
      authors,
      title,
      date,
      language,
      many-authors,
      at-university,
      university,
      date-format,
      type-of-thesis,
      course-of-studies,
      abstract-text,
      abstract-content,
      show-abstract,
      supervisor,
      keywords,
      show-declaration-of-authorship,
      declaration-of-authorship-content,
      show-confidentiality-statement,
      confidentiality-statement-content,
      university-location,
      city,
      formalities-in-frontmatter,
    )
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
    pagebreak()
  }


 // ---------- Glossary  ---------------------------------------

  if (glossary != none) {
    heading(level: 1, GLOSSARY.at(language),outlined:false)
    print-glossary(glossary)
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
    set par(leading: 15pt, justify: false)
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



  // ---------- Bibliography ---------------------------------------
counter(heading).step()
 // show std-bibliography: set heading(numbering: none)
  if bibliography != none {
    set std-bibliography(
      title: REFERENCES.at(language),
      style: bib-style,
    )
    bibliography
  }

  in-body.update(false)
  set heading(numbering: "A.1")
  //show heading: it => block(it)


  counter(heading).update(0)

  if (not formalities-in-frontmatter){
    formalities(
      authors,
      title,
      date,
      language,
      many-authors,
      at-university,
      university,
      date-format,
      type-of-thesis,
      course-of-studies,
      abstract-text,
      abstract-content,
      show-abstract,
      supervisor,
      keywords,
      show-declaration-of-authorship,
      declaration-of-authorship-content,
      show-confidentiality-statement,
      confidentiality-statement-content,
      university-location,
      city,
      formalities-in-frontmatter,
    )
  }

  // ---------- Appendix (other contents) ---------------------------------------

  if (appendix != none) {       // the user has to provide heading(s)
    appendix
  }



}
