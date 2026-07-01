// Template based on LaTeX Article Class
#let article(
  lang:"de",
  eq-numbering:none,
  text-size:10pt,
  page-numbering: "1",
  page-numbering-align: center,
  heading-numbering: "1.1  ",
  body) = {
  // Set the document's basic properties.
  set page(
    margin: (left: 25mm, right: 25mm, top: 30mm, bottom: 30mm),
    numbering: page-numbering,
    number-align: page-numbering-align,
  )
  set text(font: "New Computer Modern", lang:lang, size: text-size)
  show math.equation: set text(weight: 400)
  set math.equation(numbering: eq-numbering)
  set heading(numbering: heading-numbering)
  set outline(indent: auto)
  show outline.entry.where(
    level: 1,
  ): it => {
    v(15pt, weak: true)
    text(size:11pt ,[
      #strong(it.body)
      #box(width: 1fr, repeat[])
      #strong(it.page)
      ])}
      
  // Referencing Figures
  show figure.where(kind: table): set figure(supplement:[Tab.], numbering: "1") if lang == "de" 
  show figure.where(kind: image): set figure(supplement:[Abb.], numbering: "1",) if lang == "de"

  // Set Table style
  set table(
    stroke: none,
    gutter: auto,
    fill: none,
    inset: (right: 1.5em),
  )

  // Configure figures (tables)
  show figure.where(kind: table): it => {
    show: pad.with(x: 23pt)
    set align(center)
    v(12.5pt, weak: true)
    // Display the figure's caption.
    if it.has("caption") {
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

  // Configure figures (images)
  show figure.where(kind: image): it => {
    show: pad.with(x: 23pt)
    set align(center)
    v(12.5pt, weak: true)
    // Display the figure's body.
    it.body
    // Display the figure's caption.
    if it.has("caption") {
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



  // Main body.
  set par(justify: true)

  body
}

#let maketitle(
  title: "", 
  authors: (), 
  date: none, 
) = {
  set document(author: authors, title: title)
  // Author information.
  let authors-text = {
    set text(size: 1.1em)
    pad(
      top: 0.5em,
      bottom: 0.5em,
      x: 2em,
      grid(
        columns: (1fr,) * calc.min(3, authors.len()),
        gutter: 1em,
        ..authors.map(author => align(center, author)),
      ),
  )}
  
  // Title row.
  align(center)[
    #v(60pt)
    #block(text(weight: 400, 18pt, title))//1.75em, title))
    #v(1em, weak: true)
    #authors-text
    #v(1em, weak: true)
    #block(text(weight: 400, 1.1em, date))
    #v(20pt)
  ]
}