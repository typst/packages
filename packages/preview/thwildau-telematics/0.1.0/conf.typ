#import "@preview/hydra:0.6.2": hydra

// import all document parts
#import "sections/outlines.typ": make-other-outlines, make-outline, outline-styles
#import "sections/bibliographic_description.typ": make-bibliographic-desc
#import "sections/titlepage.typ": make-titlepage-internship, make-titlepage-content
#import "sections/reading_guides.typ": make-reading-guides
#import "sections/abbreviation_register.typ": make-abbreviation-register
#import "sections/unit_register.typ": make-unit-register
#import "sections/glossary.typ": make-glossary
#import "sections/autorship_declaration.typ": make-autorship-declaration
#import "sections/company_confirmation.typ": make-company-confirmation
#import "sections/appendix.typ": make-appendix
// import stylings
#import "components/th_color.typ": th-color
#import "components/tables.typ"
#import "components/infocard.typ": infocard
#import "components/todo.typ": todo
#import "components/unit.typ": define-unit, unit
#import "components/abbreviation.typ": abbreviation, define-abbreviation


#let conf(
  title: none,
  titlepage: "internship",
  student: none,
  supervisor: none,
  internship: none,
  bibliography: none,
  language: "de",
  reading-guides: none,
  misc-pages: (),
  doc,
) = {
  // set documents language
  set text(lang: language)

  // set page and text formatting
  set page(
    "a4",
    numbering: "I",
  )
  set par(
    justify: true,
    leading: 0.8em,
    spacing: 1.8em,
  )

  // style links
  show link: set text(
    fill: rgb(0, 91, 174),
    weight: "extralight",
    slashed-zero: true,
    ligatures: false,
    kerning: false,
    tracking: 0.45pt,
    stretch: 50%,
  )

  // numbering starts with regular text headings
  set heading(numbering: none)

  // set text style
  set text(
    size: 12pt,
    fill: luma(35%),
    spacing: 150%,
    font: "Liberation Serif",
  )

  // style headings
  show heading: it => {
    set text(font: "Liberation Sans")
    if it.level == 1 {
      // level 1 heading
      pagebreak(weak: true)
      set text(size: 24pt)
      //set block(above: 5em, below: 1.5em) // FIXME: above does not work for some reason
      block(v(4em) + it + v(1.5em))
    } else if it.level == 2 {
      // level 2 heading
      set text(size: 16pt)
      block(v(1em) + it + v(1em))
    } else if it.level == 3 {
      // level 3 heading
      set text(size: 14pt)
      block(v(0.6em) + it + v(0.6em))
    } else {
      // level 4+ heading
      it
    }
  }

  // style all outlines (outline, table register, figure register, ...)
  show: outline-styles

  // title page
  set page(footer: none)
  if titlepage == "internship" {
    make-titlepage-internship(title: title, student: student, supervisor: supervisor, internship: internship)
  } else if "content" in titlepage.keys() {
    make-titlepage-content(page-content: titlepage.content)
  }

  set page(
    margin: (
      top: 3.5cm,
      bottom: 2.5cm,
      left: 3cm,
      right: 2.5cm,
    ),
    header: context [
      #grid(
        columns: (auto, auto),
        rows: (auto, auto),
        gutter: 10pt,
        align(left)[#text(title) #linebreak() #hydra(1, skip-starting: false)],
        align(right)[#image("assets/TH-Wildau-Logo_rgb.png", width: 3.5cm)],
        grid.cell(colspan: 2, line(length: 100%, stroke: 0.5pt + gray)),
      )
    ],
    footer: context [
      #grid(
        columns: (auto, auto),
        rows: (auto, auto),
        gutter: 10pt,
        grid.cell(colspan: 2, line(length: 100%, stroke: 0.5pt + gray)),
        align(
          text(student.name + " | TH Wildau", weight: "thin", style: "italic", stretch: 200%),
        ),
        // make this more like the template, different font and maybe brighter color? Figure out how it's done!
        align(right, counter(page).display()),
      )
    ],
  )

  // style figures
  show figure.caption: set text(style: "italic", size: 11pt)
  show figure.where(kind: raw): set block(breakable: true)

  // set x-header as default table styling
  show: tables.x-header

  // make bibliographic description(s)
  if "bibliographic-description" in misc-pages {
    for (lang, desc) in misc-pages.at("bibliographic-description") [
      #make-bibliographic-desc(
        student: student,
        description: desc,
        language: lang,
      )
    ]
  }

  // Table of (text-) contents, other contents are listed below text
  make-outline()

  if "reading-guides" in misc-pages {
    make-reading-guides(reading-guides: misc-pages.at("reading-guides"))
  }

  make-abbreviation-register()

  make-unit-register()

  if "glossary" in misc-pages {
    make-glossary(glossary: misc-pages.at("glossary"))
  }

  [#metadata("before-doc") <before-doc>]

  // the user written document text
  // set numbering and heading for main document
  set page(numbering: "1.1")
  set heading(numbering: "1.1")
  show heading.where(level: 1): set heading(numbering: "1.")
  context counter(page).update(1) // make chapters in doc count separately

  // document
  doc

  // reset page counter to value before doc
  // to continue roman numerals where they were left off
  pagebreak(weak: true)
  context counter(page).update(counter(page).at(<before-doc>).first() + 1)

  set page(numbering: "I")
  set heading(numbering: none)
  show heading.where(level: 1): set heading(numbering: none)

  // List of Graphics, Tables, etc.
  make-other-outlines(bibliography: bibliography)

  // TODO: add AI declaration

  if "authorship-declaration" in misc-pages {
    make-autorship-declaration()
  }

  if "company-confirmation" in misc-pages {
    make-company-confirmation()
  }

  context counter(heading).update(0)
  set heading(numbering: "A.1")
  show heading: set heading(numbering: "A.1") 

  if "appendix" in misc-pages {
    make-appendix(misc-pages.at("appendix"))
  }
}
