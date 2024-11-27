// Thesis Template for Civil- und Environmentalengineers at TU Wien
// Sizes used across the template
#let script-size = 7pt
#let footnote-size = 8pt
#let small-size = 10pt
#let normal-size =11pt
#let large-size = 20.74pt

// Set Fonts
#let main-font = ("CMU Serif","New Computer Modern")
#let title-font = ("CMU Sans Serif", "PT Sans", "DejaVu Sans")
#let raw-font = ("DejaVu Sans Mono")

// Workaround for the lack of `std` scope
#let std-bibliography = bibliography

// This function gets your whole document as its `body` and formats
// it according to the TU Wien guidelines for thesises 
// (Diplomarbeiten, Bachelorarbeiten, Masterarbeiten)
#let tuw-thesis(
  // The Thesis Title
  title: [],
  // The type of thesis
  thesis-type: none,
  // An array of authors. For each author, you can specify a name, 
  // department, organization, location and email. Everything but the name is optional.
  authors: (),
  //Your thesis abstract. Can be omitted if you dont have one.
  abstract: none,
  // The thesis papersize. Default is A4. Affects margins.
  papersize: "a4",
  // The result of a call to the `bibliography` function or none
  bibliography: none,
  // The language of the document. Default is "de".
  lang: "de",
  //The appendix
  appendix: none,
  // The document's body
  body
) = {
  // Set language
  set text(lang: lang)

  // Formats the authors names in a list with commas and "and" at the end
  let names = authors.map(author => author.name)
  let author-string = if authors.len() == 2 {
    names.join(" and ")
  } else {
    names.join(", ", last: " and ")
  }

  // Set document metadata
  set document(title: title, author: names)

  // Set the body's font
  set text(size: normal-size, font: main-font)

  // Configure the page
  set page(
    paper: papersize,
    // The margins depend on the papersize.
    margin: (
      left: 2.5cm,
      right: 2.5cm,
      top: 2.5cm,
      bottom: 2.5cm
    ),
    // The page header should show the page number and the title, except for the first page
    // The page number is on the left for even pages and on the right for odd pages
    header-ascent: 14pt,
    header: locate(loc => {
      let i = counter(page).at(loc).first()
      if i == 1 { return }
      set text(size: normal-size)
      if calc.even(i) {
        align(center,[#i #h(1fr) #emph(title)])
      } else {
        align(center + bottom,[#emph(title) #h(1fr) #i])}
      v(5pt, weak: true)
      line(length: 100%, stroke: 0.7pt)
    }),
    )
  
  // Configure headings
  set heading(numbering: "1.1 ")
  show heading: it => [
    #set text(font: title-font)
    #block(it)
    #v(0.2em)
  ]
  
  
  // Configure lists and links
  set list(indent: 24pt, body-indent: 5pt)
  set enum(indent: 24pt, body-indent: 5pt)
  show link: set text(font: raw-font, size: small-size)
  
  // Configure equations
  show math.equation: set block(below:8pt, above: 9pt)
  show math.equation: set text(weight: 400)
  set math.equation(numbering: "(1)")

  // Configure citations and bibliography style
  set std-bibliography(style: "ieee", title: [Literatur])

  // Referencing Figures
  show figure.where(kind: table): set figure(supplement:[Tab.], numbering: "1") if lang == "de"
  show figure.where(kind: image): set figure(supplement:[Abb.], numbering: "1",) if lang == "de"


  // Configure figures 
  show figure.where(kind: table): it => {
    show: pad.with(x: 23pt)
    set align(center)
    v(12.5pt, weak: true)
    // Display the figure's caption.
    if it.has("caption") {
      // Gap defaults to 17pt. MIGHT NEED TO CHANGE THE GAPS
      v(if it.has("gap") { it.gap } else { 17pt }, weak: true)
      strong(it.supplement)
      if it.numbering != none {
        [ ]
        strong(it.counter.display(it.numbering))
      }
      [*: *]
      it.caption.body
    
    // Display the figure's body.
    it.body
    }
    v(15pt, weak: true)
  }

  show figure.where(kind: image): it => {
    show: pad.with(x: 23pt)
    set align(center)
    v(12.5pt, weak: true)
    // Display the figure's body.
    it.body
    // Display the figure's caption.
    if it.has("caption") {
      // Gap defaults to 17pt. MIGHT NEED TO CHANGE THE GAPS
      v(if it.has("gap") { it.gap } else { 17pt }, weak: true)
      strong(it.supplement)
      if it.numbering != none {
        [ ]
        strong(it.counter.display(it.numbering))
      }
      [*: *]
      it.caption.body
    }
    v(15pt, weak: true)
  }

  // Get first authors informations
  let email = authors.at(0).email
  let matrnr = authors.at(0).matrnr
  let date = authors.at(0).date


  // Display the title and authors.
  v(50pt, weak: false)
  align(center, {
    text(font: title-font, size: large-size, weight: 500, thesis-type)
    v(25pt, weak: true)
    text(font: title-font, size: large-size, weight: 700, title)
    v(25pt, weak: true)
    text(font: title-font, size: normal-size, author-string)
    v(15pt, weak: true)
    if lang == "de" {
      // German
      text(font: title-font, size: small-size, 
        [#email\
        Matr.Nr.: #matrnr \
        Datum: #date])
    } else {
      // English
      text(font: title-font, size: small-size, 
        [#email\
        Matr.Nr.: #matrnr \
        Date: #date])
    }
  })

  // Configure paragraph properties.
  set par(first-line-indent: 1.8em, justify: true, leading: 0.55em)
  show par: set block(spacing: 0.65em) //above: 1.4em, below: 1em, 

  // Configure raw text
  show raw: set text(font: raw-font, size: small-size)

  // Set Table style
  set table(
    stroke: none,
    gutter: auto,
    fill: none,
    inset: (right: 1.5em),
  )


  // Display the abstract
  if abstract != none and lang != "de"{
    // English abstract
    v(50pt, weak: true)
    set text(small-size)
    show: pad.with(x: 1cm)
    align(center,text(font:title-font, strong[Abstract]))
    v(6pt, weak: true)
    abstract
  } else if abstract != none and lang == "de"{
    // German abstract
    v(50pt, weak: true)
    set text(small-size)
    show: pad.with(x: 1cm)
    align(center,text(font:title-font, strong[Kurzfassung]))
    v(6pt, weak: true)
    abstract
  } else {
    // No abstract
    v(50pt, weak: true)
  }
// Table of Contents Style
  show outline.entry.where(
    level: 1,
  ): it => {
    v(15pt, weak: true)
    text(font:title-font, size:11pt ,[
      #strong(it.body)
      #box(width: 1fr, repeat[])
      #strong(it.page)
      ])}

  show outline.entry.where(
    level: 2,
  ): it => {
    it.body
    box(width: 1fr, repeat[.])
    it.page}

  show outline.entry.where(
    level: 3,
  ): it => {
    it.body
    box(width: 1fr, repeat[.])
    it.page}


  // Display the table of contents.
  if lang == "de" {
    outline(title: [Inhaltsverzeichnis], indent: auto)
  } else {
      outline(title: [Table of Contents], indent: auto)

  }

  // Display the article's contents.
  v(29pt, weak: true)
  body

  // Display the bibliography, if any is given.
  if bibliography != none {
    pagebreak()
    show std-bibliography: set text(normal-size)
    show std-bibliography: pad.with(x: 0.5pt)
    bibliography
  }

  // Appendix
  if appendix != none {
    set heading(numbering: none)
    [= Anhang]
    set outline(depth: 2)
    set heading(numbering: (..nums) => {
      nums = nums.pos()
      if nums.len() == 1 {
        return "Anhang " + numbering("A.", ..nums)
      } else if nums.len() == 2 {
        return numbering("A.1.", ..nums)
      } else {
        return numbering("A.1.", ..nums)
      }
    })
  show heading.where(level: 3): set heading(numbering: "A.1", outlined: false)
  show heading.where(level: 2): set heading(numbering: "A.1", outlined: false)
  counter(heading).update(0)
  appendix
  }
}

#let codecell(
  doc, 
  // Vertical shift (space before cell)
  vertical:1em
) = {
  if vertical != none {
    v(vertical)
  }
  figure(
    box(
      align(left,doc),
      stroke: 0.7pt , 
      fill: rgb("#eee"), 
      outset: 5pt, 
      radius: 7pt, 
      width: 75%))
}
