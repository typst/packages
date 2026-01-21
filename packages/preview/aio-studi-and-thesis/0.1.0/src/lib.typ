#import "@preview/glossarium:0.4.1": gls, glspl
#import "@preview/codly:1.0.0": *

#import "utils.typ": *

#import "assets.typ": *
#import "pm_assets.typ": *

#let project(
  lang: "de",
  authors: (
    (
      name: "Unknown author", // required
      id: "",
      email: ""
    ),
  ),
  title: "Unknown title",
  subtitle: none,
  date: none,
  version: none,
  thesis-compliant: false,

  // Format
  side-margins: (
    left: 3.5cm,  // required
    right: 3.5cm, // required
    top: 3.5cm,   // required
    bottom: 3.5cm // required
  ),
  h1-spacing: 0.5em,
  line-spacing: 0.65em,
  font: "Roboto",
  font-size: 11pt,
  hyphenate: false,

  // Color settings
  primary-color: dark-blue,
  secondary-color: blue,
  text-color: dark-grey,
  background-color: light-blue,

  // Cover sheet
  custom-cover-sheet: none,
  cover-sheet: (    // none
    university: (   // none
      name: none,   // required
      street: none, // required
      city: none,   // required
      logo: none
    ), 
    employer: (     // none
      name: none,   // required
      street: none, // required
      city: none,   // required
      logo: none
    ), 
    cover-image: none,
    description: none,
    faculty: none,
    programme: none,
    semester: none,
    course: none,
    examiner: none,
    submission-date: none
  ),

  // Declaration
  custom-declaration: none,
  declaration-on-the-final-thesis: (             // none
    legal-reference: none,                       // required
    thesis-name: none,                           // required
    consent-to-publication-in-the-library: none, // required | true, false
    genitive-of-university: none                 // required
  ),

  // Abstract
  abstract: none,

  // Outlines
  depth-toc: 4,
  outlines-indent: 1em,
  show-list-of-figures: false,
  show-list-of-abbreviations: true,
  list-of-abbreviations: (
    (
      key: "",    // required
      short: "",  // required
      plural: "",
      long: "",
      longplural: "",
      desc: none,
      group: "",
    ),
  ),
  show-list-of-formulas: false,
  custom-outlines: ( // none
    (
      title: none,   // required
      custom: none   // required
    ),
  ),
  show-list-of-tables: false,
  show-list-of-todos: false,
  literature-and-bibliography: none,
  list-of-attachements: ( // none
    (a: none),            // required
  ),
  
  body
) = {
  import "@preview/hydra:0.5.1": hydra
  import "@preview/glossarium:0.4.1": make-glossary as make-list-of-abbreviations, print-glossary as print-list-of-abbreviations
  
  import "dictionary.typ": *
  import "cover_sheet.typ": *
  import "declaration_on_the_final_thesis.typ": *

  // Metadata
  let date-format = if lang == "de" { "[day].[month].[year]" } else { "[day]/[month]/[year]" }

  set document(
    title: title + if is-not-none-or-empty(version) { " v" + version },
    author: authors.map(a => a.name)
  )
  
  // Basics
  set page(
    paper: "a4",
    flipped: false,
    margin: side-margins
  )

  set text(
    lang: lang,
    font: font,
    size: font-size,
    fill: text-color
  )

  use-dictionary()
  
  show: make-list-of-abbreviations
  show: codly-init.with()

  if is-not-none-or-empty(date) == false {
    date = datetime.today().display(date-format)
  }
  
  // Cover Sheet
  if is-not-none-or-empty(custom-cover-sheet) == false and is-not-none-or-empty(cover-sheet) {
    let cover-sheet-dict-contains-key(key) = {
      return dict-contains-key(dict: cover-sheet, key)
    }
    
    get-cover-sheet(
      primary-color: primary-color,
      secondary-color: secondary-color,
      text-color: text-color,
      background-color: background-color,
      visualise-content-boxes: (flag: false, fill: background-color, stroke: text-color),
      university: if cover-sheet-dict-contains-key("university") { cover-sheet.university },
      employer: if cover-sheet-dict-contains-key("employer") { cover-sheet.employer },
      cover-image: if cover-sheet-dict-contains-key("cover-image") { cover-sheet.cover-image },
      date: date,
      version: version,
      title: title,
      subtitle: subtitle,
      description: if cover-sheet-dict-contains-key("description") { cover-sheet.description },
      authors: authors,
      faculty: if cover-sheet-dict-contains-key("faculty") { cover-sheet.faculty },
      programme: if cover-sheet-dict-contains-key("programme") { cover-sheet.programme },
      semester: if cover-sheet-dict-contains-key("semester") { cover-sheet.semester },
      course: if cover-sheet-dict-contains-key("course") { cover-sheet.course },
      examiner: if cover-sheet-dict-contains-key("examiner") { cover-sheet.examiner },
      submission-date: if cover-sheet-dict-contains-key("submission-date") { cover-sheet.submission-date }
    )
  } else {
    custom-cover-sheet
  }
  pagebreak()

  // Content basics
  show heading.where(level: 1): set text(fill: primary-color)
  show heading.where(level: 1): it => if thesis-compliant { colbreak(weak: true) } + it + v(h1-spacing)
  
  set page(
    numbering: "1",
    header: context {
      if thesis-compliant {
        align(
          left,
          text(weight: "bold", size: 8.5pt)[
            #let h1 = hydra(1, skip-starting: false)

            #let numbered-heading = to-string(h1).split(regex("[.]\s")).at(1, default: none)
            #if numbered-heading != none {
              numbered-heading
            } else {
              h1
            }
          ]
        )
        v(-1em)
        line(length: 100%, stroke: 1.2pt + text-color)
      }
    }
  )

  set par(
    leading: line-spacing,
    justify: true
  )
  
  set text(
    hyphenate: hyphenate
  )

  let get-figure-caption(it) = [
    #set align(left)
    #h(1em)
    #box[
      #it.supplement
      #context it.counter.display(it.numbering):
      #text(fill: primary-color)[*#it.body*]
    ]
  ]
  
  show figure.caption.where(kind: image): it => get-figure-caption(it)
  show figure.caption.where(kind: table): it => get-figure-caption(it)

  show link: set text(fill: secondary-color.darken(60%))

  // Declaration
  if is-not-none-or-empty(custom-declaration) {
    page(
      header: "",
      footer: ""
    )[
      #custom-declaration
    ]
  }
  else if thesis-compliant and is-not-none-or-empty(declaration-on-the-final-thesis) {
    page(
      header: "",
      footer: ""
    )[
      #get-declaration-on-the-final-thesis(
        lang: lang,
        legal-reference: declaration-on-the-final-thesis.legal-reference,
        thesis-name: declaration-on-the-final-thesis.thesis-name,
        consent-to-publication-in-the-library: declaration-on-the-final-thesis.consent-to-publication-in-the-library,
        genitive-of-university: declaration-on-the-final-thesis.genitive-of-university
      )
    ]
  }

  // Abstract
  if is-not-none-or-empty(abstract) {
    page(
      numbering: "I"
    )[
      #counter(page).update(1)
      #heading(depth: 1)[ #txt-abstract ]
      #abstract
    ]
  }

  // Table of contents (TOC)
  page(
    numbering: none
  )[
    #if is-not-none-or-empty(abstract) == false { counter(page).update(1) }
      
    #show outline.entry.where(level: 1): it => {
      v(1.5em, weak: true)
      upper(strong(it))
    }

    #outline(
      indent: outlines-indent,
      depth: depth-toc
    ) 
  ]

  // List of Figures
  if thesis-compliant or show-list-of-figures {
    page(
      numbering: "I"
    )[
      #heading(depth: 1)[ #txt-list-of-figures ]

      #simple-outline(
        indent: outlines-indent,
        target: figure.where(kind: image)
      )
    ]
  }

  // List of Abbreviations
  if show-list-of-abbreviations and is-not-none-or-empty(list-of-abbreviations){
    if is-not-none-or-empty(list-of-abbreviations.at(0).key) and is-not-none-or-empty(list-of-abbreviations.at(0).short) {
      page(
        numbering: "I"
      )[
        #heading(depth: 1)[ #txt-list-of-abbreviations ]
        #print-list-of-abbreviations(list-of-abbreviations)
      ]
    }
  }
  
  // List of Formulas
  set math.equation(numbering: if thesis-compliant or show-list-of-formulas { "(1)" } else { none }, supplement: [#txt-supplement-formula])

  show math.equation.where(block: true) : it => rect(width: 100%, fill: background-color)[
    #v(0.5em)
    #it
    #v(0.5em)
  ]
  
  if show-list-of-formulas {  
    page(
      numbering: "I"
    )[
      #simple-outline(
        title: txt-list-of-formulas,
        indent: outlines-indent,
        target: math.equation.where(block: true)
      )
    ]
  }

  // Custom outlines
  if is-not-none-or-empty(custom-outlines) {
    for o in custom-outlines {
      if o.title != none and o.custom != none {
        page(
          numbering: "I"
        )[
          #if is-not-none-or-empty(o.title) {
            heading(depth: 1)[ #o.title ]
          }
          #o.custom
        ]
      }
    }
  }

  // List of Tables
  if show-list-of-tables {
    page(
      numbering: "I"
    )[
      #simple-outline(
        title: txt-list-of-tables,
        indent: outlines-indent,
        target: figure.where(kind: table)
      )
    ]
  }

  // Body
  set page(
    footer: if thesis-compliant == false [
      #set text(weight: "regular")
      #let size = 11pt
      
      #context {
        grid(
          columns: (1fr, auto, 1fr),
          align: (left, center, right),
          gutter: size,
          [
            #text(fill: text-color, size: size)[ #date ]
          ],
          [
            #text(fill: primary-color, size: size + 1pt)[ *#title* ] \ 
            #text(fill: secondary-color, size: size)[ #subtitle ]
          ],
          [
            #text(fill: text-color, size: size)[ #counter(page).display() / #counter(page).final().last() ]
          ]
        )
      }
    ]
  )
  
  counter(page).update(1)

  let todos() = {
    locate(loc => {
      let elems = query(<todo>, loc)
    
      if elems.len() == 0 { return }

      heading(depth: 1)[ TODOs ]
    
      for body in elems {
        text([+ #link(body.location(), body.text)], red)
      }
    })
  }

  if show-list-of-todos { todos() }
  
  set heading(numbering: "1.1.")
  
  body

  // Literature, bibliography, attachements
  set heading(numbering: none)

  if is-not-none-or-empty(literature-and-bibliography) {
    page[
      #heading(depth: 1)[ #txt-literature-and-bibliography ]
      #literature-and-bibliography
    ]
  }

  if is-not-none-or-empty(list-of-attachements) and (thesis-compliant or list-of-attachements.at(0).a != none) {
    page[
      #heading(depth: 1)[ #txt-list-of-attachements ]

      #v(1.5em)
      
      #let index = 1
      #for c in list-of-attachements {
        text()[ #txt-attachement A#index: #c.a ]
        v(1em)
        index = index + 1
      }
    ]
  }
}