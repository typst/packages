// Template for ISC reports at the School of engineering
// v0.2.0 - since 2024, pmudry with contributions from @LordBaryhobal, @MadeInShineA
//
// Missing features :
// - page and locations (above, under) references for figures not available yet

// Fancy pretty print with line numbers and stuff
#import "@preview/codelst:2.0.2": sourcecode

// Nice color boxes
#import "@preview/showybox:2.0.3": showybox

// Define our own functions
#let todo(body, fill-color: yellow.lighten(50%)) = {
  set text(black)
  box(
    baseline: 25%,
    fill: fill-color,
    inset: 3pt,
    [*TODO* #body],
  )
}

//
// Multiple languages support
//

// Thanks @LordBaryhobal for the original idea
#let langs = json("i18n.json")

#let i18n(lang, key, extra-i18n: none) = {
  let langs = langs
  if type(extra-i18n) == dictionary {
    for (lng, keys) in extra-i18n {
      if not lng in langs {
        langs.insert(lng, (:))
      }
      langs.at(lng) += keys
    }
  }
  
  if not lang in langs {
    lang = "fr"
  }
  
  let keys = langs.at(lang)

  assert(
    key in keys,
    message: "I18n key " + str(key) + " doesn't exist"
  )
  return keys.at(key)
}

#let make-outline(font: auto, title, ..args) = {
  let title = if font == auto {title} else {
    text(font: font, title)
  }
  outline(
    title: {
      v(5em)
      text(size: 1.5em, weight: 700, title)
      v(3em)
    },
    indent: 2em,
    ..args
  )
  pagebreak(weak: true)
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
  academic-year: [2023-2025],

  cover-image: none,
  cover-image-height: 10cm,
  cover-image-caption: [KNN graph -- Inspired by _Marcus Volg_],
  cover-image-kind: auto,
  cover-image-supplement: auto,
  
  // A list of authors, separated by commas
  authors: (),
  date: none,
  logo: none,

  tables: (
    contents: true,
    figures: false,
    tables: false,
    listings: false,
    equations: false
  ),

  version : "0.2.0",
  language : "fr", 
  extra-i18n : none,
  code-theme: "bluloco-light",
  body,
) = {

  let i18n = i18n.with(extra-i18n: extra-i18n, language)
 
  // Set the document's basic properties.
  set document(author: authors, title: title)

  // Document language for hyphenation and other things
  let internal-language = language

  //
  //  Fonts
  //
  let body-font = ("Source Sans Pro", "Source Sans 3", "Libertinus Serif")
  let sans-font = ("Source Sans Pro", "Source Sans 3", "Inria Sans")
  let raw-font = "Fira Code"
  let math-font = ("Asana Math", "Fira Math")

  // Default body font
  set text(font: body-font, lang: internal-language)
  
  // Set other fonts
  // show math.equation: set text(font: math-font) // For math equations
  let selected-theme = "template/themes/" + code-theme + ".tmTheme"
  set raw(theme: selected-theme)
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
    #emph(version)
  ]

  let footer-content = context text(0.75em)[
    #emph(title)
    #h(1fr)
    #counter(page).display(
      "1/1",
      both: true
    )
  ]

  // Set header and footers
  set page(
    // For pages other than the first one
    header: context if counter(page).get().first() > 1 {
      header-content
    },
    header-ascent: 40%,

    // For pages other than the first one
    footer: context if counter(page).get().first() > 1 [
      #move(dy: 5pt, line(length: 100%, stroke: 0.5pt))
      #footer-content
    ]
  )
  
  // Links coloring
  show link: set text(ligatures: true, fill: blue)

  // Sections numbers
  set heading(numbering: "1.1.1 -")

  /////////////////////////////////////////////////
  // Handle specific captions styling
  /////////////////////////////////////////////////

  // Compute a suitable supplement as they are not to my liking
  let getSupplement(it) = {
    let f = it.func()
    if (f == image) {
      i18n("figure-name")
    } else if (f == table) {
      i18n("table-name")
    } else if (f == raw) {
      i18n("listing-name")
    } else {
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
  show figure.caption: it => context {
      if it.numbering == none {
        it.body
      } else {
        it.supplement + " " + it.counter.display() + it.separator + it.body
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
  show figure.where(kind: raw): set block(breakable: true)

  /////////////////////////////////////////////////
  // Our own specific commands
  /////////////////////////////////////////////////
  let insert-logo(logo) = {
    if logo != none {
      place(
        top + right,
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
  insert-logo(logo)
  
  let title-block = [
    #course-supervisor\
    #semester #academic-year
  ]
  let title-block-content = title-block

  place(
    top + left,
    dy: -2em,
    text(1em)[
      #text(weight: 700, course-name)\
      #text(title-block-content)
    ]
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
  text(font: sans-font, 2em, weight: 700, smallcaps(title))
  set par(leading: 0.65em)
  
  // Subtitle
  v(1em, weak: true)
  text(font: sans-font, 1.2em, sub-title)
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

  let make-outline = make-outline.with(
    font: body-font
  )
  
  if tables != none {
    if tables.at("contents", default: false) {
      make-outline(
        i18n("toc-title"),
        depth: 2
      )
    }
    if tables.at("figures", default: false) {
      make-outline(
        i18n("figure-table-title"),
        target: figure.where(kind: image)
      )
    }
    if tables.at("tables", default: false) {
      make-outline(
        i18n("table-table-title"),
        target: figure.where(kind: table)
      )
    }
    if tables.at("listings", default: false) {
      make-outline(
        i18n("listing-table-title"),
        target: figure.where(kind: raw)
      )
    }
    if tables.at("equations", default: false) {
      make-outline(
        i18n("equation-table-title"),
        target: math.equation.where(block:true)
      )
    }
  }

  // Main body.
  set par(justify: true)

  body
}