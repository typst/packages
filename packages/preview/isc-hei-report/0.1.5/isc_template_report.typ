// Template for ISC reports at the School of engineering
// v0.1.5 - mui 2024
//
// Missing features : 
// - page and locations (above, under) references for figures not available yet

// Fancy pretty print with line numbers and stuff
#import "@preview/codelst:2.0.1": sourcecode 

// Nice color boxes
#import "@preview/showybox:2.0.1": showybox

// Define our own functions
#let todo(body, fill-color: yellow.lighten(50%)) = {
  set text(black)
  box(
    baseline:25%,
    fill: fill-color,
    inset: 3pt,
    [*TODO* #body],
  )
}

//
// Multiple languages support
//

// Thanks @LordBaryhobal for the original idea
#let langs = (
  fr: (
    toc-title: "Table des matières",
    bib-title: "Bibliographie",
    chapter-title: "Chapitre",
    figure-name: "Figure",
    table-name: "Table",
    listing-name: "Listing",    
    appendix-title: "Annexes",
    appendix-code-name: "Code annexé",
    acronym-table-title: "Table des acronymes",
    figure-table-title: "Table des figures",
    listing-table-title: "Table des listings",    
    table-table-title: "Table des tableaux",    
  ),
  en: (
    toc-title: "Table of contents",
    bib-title: "Bibliography",
    chapter-title: "Chapter",
    figure-name: "Figure",
    table-name: "Table",
    listing-name: "Listing",
    appendix-code-name: "Code appendix",
    appendix-title: "Appendix",
    acronym-table-title: "Table of acronyms",
    figure-table-title: "List of figures",
    listing-table-title: "List of listings",
    table-table-title: "List of tables",
  ),
  de: (
    toc-title: "Inhaltsverzeichnis",
    bib-title: "Literatur",
    chapter-title: "Kapitel",
    figure-name: "Abb.",    
    table-name: "Tabelle",
    listing-name: "Listing",
    appendix-code-name: "Kode Anhang",
    appendix-title: "Anhang",
    acronym-table-title: "Akronymtabelle",
    figure-table-title: "Abbildungen",
    listing-table-title: "Quelltexte",
    table-table-title: "Tabellen",
  ),
)

#let i18n(lang, key) = {
  if not lang in langs {
    lang = "fr"
  }
  
  let keys = langs.at(lang)

  if not key in keys {
    panic("I18n key " + key + "doesn't exist")
  }
  return keys.at(key)
}


//
// Source code inclusion
//
#let _luma-background = luma(250)

// Replace the original function by ours
#let codelst-sourcecode = sourcecode
#let code = codelst-sourcecode.with(
  frame: block.with(    
    fill: _luma-background,
    stroke: 0.5pt + luma(80%),
    radius: 3pt,
    inset: (x: 6pt, y: 7pt)
  ),
  numbering: "1",
  numbers-style: (lno) => text(luma(210), size:7pt, lno),
  numbers-step: 1,
  numbers-width: -1em,
  gutter:1.2em
)

// The template itself
#let project(
  title: [Report title],
  sub-title: [Report sub-title], 
  
  course-name: [Course name],
  course-supervisor: [Course supervisor],
  semester: [Semester],
  academic-year: [2023-2024],

  cover-image: none,
  cover-image-height: 10cm,
  cover-image-caption: "KNN exposed, by Marcus Volg",
  cover-image-kind: auto,
  cover-image-supplement: auto,
    
  // A list of authors, separated by commas
  authors: (),
  date: none,
  logo: none,

  version : "1.0.0",
  language : "fr",
  body,
) = {
 
  // Set the document's basic properties.
  set document(author: authors, title: title)

  // Document language for hyphenation and other things   
  let internal-language = language

  // 
  //  Fonts 
  //   
  let body-font = ("Source Sans Pro", "Source Sans 3", "Linux Libertine")
  let sans-font = ("Source Sans Pro", "Source Sans 3", "Inria Sans")
  let raw-font = "Fira Code"
  let math-font = ("Asana Math", "Fira Math")

  // Default body font
  set text(font: body-font, lang: internal-language)
  
  // Set other fonts
  // show math.equation: set text(font: math-font) // For math equations
  show raw: set text(font: raw-font) // For code
  show heading: set text(font: sans-font) // For sections, sub-sections etc..

  /////////////////////////////////////////////////
  // Citation style
  /////////////////////////////////////////////////
  set cite(style: auto, form: "normal")  

  /////////////////////////////////////////////////
  //  Basic pagination and typesetting
  /////////////////////////////////////////////////
  set page(        
    margin: (inside: 2.5cm, outside: 2cm, y: 2.1cm), // Binding inside
    paper: "a4"
  )  

  let space-after-heading = 0.5em
  show heading: it => {it; v(space-after-heading)} // Space after heading
  
  let authors-str = ()

  if (authors.len() > 1){
     authors-str = authors.join(", ")
  }
  else{
     authors-str = authors.at(0)
  }

  let header-content = text(0.75em)[
    #emph(authors-str)
    #h(1fr)    
    #emph(eval(version, mode: "markup"))
  ]

  let footer-content = text(0.75em)[    
    #emph(eval(title, mode: "markup"))  
    #h(1fr)    
    #counter(page).display(
          "1/1",
          both: true
        )
  ]

  // Set header and footers
  set page(    
    header: locate(loc => {
      // For pages other than the first one
      if counter(page).at(loc).first() > 1 {
        header-content
      }
    }),

    header-ascent: 40%,

    footer: locate(loc => {
      // For pages other than the first one
      if counter(page).at(loc).first() > 1 [
        #move(dy:5pt, line(length: 100%, stroke: 0.5pt))
        #footer-content
      ]
    })
  )  
  
  // Links coloring
  show link: set text(ligatures: true, fill: blue)

  // Sections numbers 
  set heading(numbering: "1.1.1 -")

  /////////////////////////////////////////////////
  // Handle specific captions styling
  /////////////////////////////////////////////////  
  
  // TODO : Make this suitable for different languages

  // Compute a suitable supplement as they are not to my liking
  let getSupplement(it) = {        
    if(it.func() == image){
      i18n(internal-language, "figure-name")
    } else if (it.func() == table){
      i18n(internal-language, "table-name")
    } else if (it.func() == raw){
      i18n(internal-language, "listing-name")
    } else{
      auto
    }
  }  

  set figure(numbering: "1", supplement: getSupplement)

  // Make the caption like I like them
  show figure.caption: set text(9pt) // Smaller font size
  show figure.caption: emph // Use italics  
  set figure.caption(separator: " - ") // With a nice separator
  
  show figure.caption: it => {it.counter.display()} // Used for debugging

  // Make the caption like I like them  
  show figure.caption: it => {
      if it.numbering == none {
        eval(mode:"markup", it.body.text) 
      } else { 
        it.supplement + " " + it.counter.display() + it.separator + eval(mode:"markup", it.body.text)
      }                                
    }
  
  /////////////////////////////////////////////////
  // Code related, only for inline as the
  // code block is handled by function at the top of the file
  /////////////////////////////////////////////////
  
  // Inline code display, 
  // In a small box that retains the correct baseline.
  show raw.where(block: false): box.with(
    fill: _luma-background,
    inset: (x: 2pt, y: 0pt),
    outset: (y: 2pt),
    radius: 1pt,
  )
    
  // Allow page breaks for raw figures
  show figure.where(kind:raw): set block(breakable: true)

  /////////////////////////////////////////////////
  // Our own specific commands
  /////////////////////////////////////////////////  
  let insertLogo(logo) = {
    if logo != none {  
      place(top + right,
        dx: 6mm,
        dy: -12mm,
        clearance: 0em,
        // Put it in a box to be resized
        box(height:2.0cm, logo)
      )      
    }
  }

  /////////////////////////////////////////////////
  // Let's make the template now
  /////////////////////////////////////////////////

  // Title page.
  insertLogo(logo)
  
  let title-block = course-supervisor + "\n" + semester + " " + academic-year
  let title-block-content = title-block

  place(top + left,
    dy: -2em,
      text(1em, 
      text(weight: 700, course-name) + "\n" + text(title-block-content)
      )
  )

  v(10fr, weak: true)

  // Puts a default cover image
  if cover-image != none {
    show figure.caption: emph
    figure(
      box(cover-image, height: cover-image-height),
      caption: cover-image-caption,
      numbering: none,
      kind: cover-image-kind,
      supplement: cover-image-supplement
    )
  }

  v(10fr, weak: true)

  // Main title
  set par(leading: 0.2em)
  text(font: sans-font, 2em, weight: 700, smallcaps(eval(title, mode:"markup")))
  set par(leading: 0.65em)
  
  // Subtitle
  v(1em, weak: true)
  text(font: sans-font, 1.2em, eval(sub-title, mode:"markup"))
  line(length: 100%)
  
  v(4em)

  // Author information on the title page
  pad(
    top: 1em,
    right: 20%,    
    grid(
      columns: 3,
      column-gutter: 3em,
      gutter: 2em,
      ..authors.map(author => align(start, text(1.1em, strong(author)))),
    ),
  )
  
  // The date
  text(1.1em, date)

  v(2.4fr)
  pagebreak()
  
  // --- Table of Contents ---
  outline(
    title: {
      v(5em)
      text(font: body-font, 1.5em, weight: 700, i18n(internal-language, "toc-title"))
      v(3em)
    },
    indent: 2em,
    depth: 2
  )
  
  pagebreak()

  // Main body.
  set par(justify: true)

  body
}