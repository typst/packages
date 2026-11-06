#let layouts = (
  "small": ("height": 9cm, "space": 1.4cm),
  "medium": ("height": 10.5cm, "space": 1.6cm),
  "large": ("height": 12cm, "space": 1.8cm),
)

#let slides(
  content,
  title: none,
  subtitle: none,
  date: none,
  authors: (),
  layout: "medium",
  ratio: 4/3,
  title-color: none,
  count: true,
  footer: true,
  toc: true,
) = {

  // Parsing
  if layout not in layouts {
      panic("Unknown layout " + layout)
  }
  let (height, space) = layouts.at(layout)
  let width = ratio * height

  // Colors
  if title-color == none {
      title-color = blue.darken(50%)
  }
  let block-color = title-color.lighten(90%)
  let body-color = title-color.lighten(80%)
  let header-color = title-color.lighten(65%)
  let fill-color = title-color.lighten(50%)

  // Setup
  set document(
    title: title,
    author: authors,
  )
  set heading(numbering: "1.a")

  // PAGE----------------------------------------------
  set page(
    width: width,
    height: height,
    margin: (x: 0.5 * space, top: space, bottom: 0.6 * space),
    header: [
      #context {  
        let page = here().page()
        let headings = query(selector(heading.where(level: 2)))
        let heading = headings.rev().find(x => x.location().page() <= page)
        if heading != none {
          set align(top)
          set text(1.4em, weight: "bold", fill: title-color)
          v(space / 2)
          block(heading.body +
            if not heading.location().page() == page [
              #{numbering("(i)", page - heading.location().page() + 1)}
            ]
          )
        }
    }
    // Count for Page Dots
    #if count == true {
      v(-space/1.5)
      align(right+top)[
        #context {
          let last = counter(page).final().first()
          let current = here().page()
          // Before the current page
          for i in range(1,current) {
            link((page:i, x:0pt,y:0pt))[
              #box(circle(radius: 0.08cm, fill: fill-color, stroke: 1pt+fill-color)) 
            ]
          }
          // Current Page
          link((page:current, x:0pt,y:0pt))[
              #box(circle(radius: 0.08cm, fill: fill-color, stroke: 1pt+fill-color)) 
            ]
          // After the current page
          for i in range(current+1,last+1) {
            link((page:i, x:0pt,y:0pt))[
              #box(circle(radius: 0.08cm, stroke: 1pt+fill-color)) 
            ]
          }
          }
        ] 
      }
    ],
    header-ascent: 0%,
    // Footer
    footer: [
      #if footer == true {
        
        set text(0.7em)
        box()[#line(length: 50%, stroke: 2pt+fill-color )]
        box()[#line(length: 50%, stroke: 2pt+body-color)]
        v(-0.3cm)
        grid(
          columns: (1fr, 1fr),
          align: (right,left),
          inset: 4pt,
          [#smallcaps()[#title]],
          [ #if subtitle != none {
              subtitle
            } else if authors != none {
                if (type(authors) != array) {authors = (authors,)}
                authors.join(", ", last: " and ")
              } else [#date]
          ],
          
        )
    } 
    ],
    footer-descent:0.8em,
  )


  // SLIDES STYLING--------------------------------------------------
  // Section Slides
  show heading.where(level: 1): x => {
    set page(header: none,footer: none, margin: 0cm)
    set align(horizon)
      grid(
        columns: (1fr, 3fr),
        inset: 10pt,
        align: (right,left),
        fill: (title-color, white),
        [#block(height: 100%)],[#text(1.2em, weight: "bold", fill: title-color)[#x]]
      )

  }
  show heading.where(level: 2): pagebreak(weak: true) // this is where the magic happens
  show heading: set text(1.1em, fill: title-color)

  // Title Slide
  if (title == none) {
    panic("A title is required")
  }
  else {
    if (type(authors) != array) {
      authors = (authors,)
    }
    set page(footer: none, header: none, margin: 0cm)
    block(
      inset: (x:0.5*space, y:1em),
      fill: title-color,
      width: 100%,
      height: 60%,
      align(bottom)[#text(2.0em, weight: "bold", fill: white, title)]
    )
    block(
      height: 30%,
      width: 100%,
      inset: (x:0.5*space,top:0cm, bottom: 1em),
      if subtitle != none {[
        #text(1.4em, fill: title-color, weight: "bold", subtitle)
      ]} + 
      if subtitle != none and date != none { text(1.4em)[ \ ] } +
      if date != none {text(1.1em, date)} +
      align(left+bottom, authors.join(", ", last: " and "))
    )
  }


  // ADD. STYLING --------------------------------------------------
  // Terms
  show terms.item: it => {
    set block(width: 100%, inset: 5pt)
    stack(
      block(fill: header-color, radius: (top: 0.2em, bottom: 0cm), strong(it.term)),
      block(fill: block-color, radius: (top: 0cm, bottom: 0.2em), it.description),
    )
  }

  // Code
  show raw.where(block: false): it => {
    box(fill: block-color, inset: 1pt, radius: 1pt, baseline: 1pt)[#text(size:8pt ,it)]
  }

  show raw.where(block: true): it => { 
    block(radius: 0.5em, fill: block-color, 
          width: 100%, inset: 1em, it)
  }

  // Bullet List
  show list: set list(marker: (
    text(fill: title-color)[•],
    text(fill: title-color)[‣],
    text(fill: title-color)[-],
  ))

  // Enum
  let color_number(nrs) = text(fill:title-color)[*#nrs.*]
  set enum(numbering: color_number)

  // Table
  show table: set table(
    stroke: (x, y) => (
      x: none,
      bottom: 0.8pt+black,
      top: if y == 0 {0.8pt+black} else if y==1 {0.4pt+black} else { 0pt },
    )
  )
  
  show table.cell.where(y: 0): set text(
    style: "normal", weight: "bold") // for first / header row

  set table.hline(stroke: 0.4pt+black)
  set table.vline(stroke: 0.4pt)

  // Quote
  set quote(block: true)
  show quote.where(block: true): it => {
    v(-5pt)
    block(
      fill: block-color, inset: 5pt, radius: 1pt, 
      stroke: (left: 3pt+fill-color), width: 100%, 
      outset: (left:-5pt, right:-5pt, top: 5pt, bottom: 5pt)
      )[#it]
    v(-5pt)
  }

  // Link
  show link: it => {
    if type(it.dest) != str { // Local Links
      it
    }
    else {
      underline(stroke: 0.5pt+title-color)[#it] // Web Links
    } 
  }

  // Outline
  set outline(
    // target: heading.where(level: 1),
    indent: true,
  )
  
  show outline: set heading(level: 2) // To not make the TOC heading a section slide by itself

  if (toc == true) {
    outline()
  }

  // Bibliography
  set bibliography(
    title: none
  )
  

  // CONTENT---------------------------------------------
  content
}