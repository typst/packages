#import "@preview/subpar:0.1.1"
#import "@preview/physica:0.9.3": *

#let stroke-color = luma(200)
#let std-bibliography = bibliography
#let isappendix = state("isappendix", false)

#let front-matter(body) = {
  set page(numbering: "i")
  set heading(numbering: none)
  body
}

#let main-matter(body) = {
  set page(numbering: "1")
  counter(page).update(1)
  counter(heading).update(0)
  set heading(numbering: "1.1")
  body
}

#let subfigure = {
  subpar.grid.with(
    numbering: n => if isappendix.get() {numbering("A.1", counter(heading).get().first(), n)
      } else {
        numbering("1.1", counter(heading).get().first(), n)
      },
    numbering-sub-ref: (m, n) => if isappendix.get() {numbering("A.1a", counter(heading).get().first(), m, n)
      } else {
        numbering("a", m, n)
      }
  )
}

#let nifty-ntnu-thesis(
  title: [Title],
  short-title: [],
  authors: ("Author"),
  short-author: none,
  font: "Charter",
  raw-font: "DejaVu Sans Mono",
  paper-size: "a4",
  date: datetime.today(),
  date-format: "[day padding:zero]/[month repr:numerical]/[year repr:full]",
  abstract-en: none,
  abstract-no: none,
  preface: none,
  table-of-contents: outline(),
  titlepage: true,
  bibliography: none,
  chapter-pagebreak: true,
  chapters-on-odd: false,
  figure-index: (
    enabled: true,
    title: "Figures",
  ),
  table-index: (
    enabled: true,
    title: "Tables",
  ),
  listing-index: (
    enabled: true,
    title: "Code listings",
  ),
  body,
) =  {
  set document(title: title, author: authors)
  // Set text fonts and sizes
  set text(font: font, size: 11pt)
  show raw: set text(font: raw-font, size: 9pt)
  //Paper setup
  set page(
    paper: paper-size,
    margin: (bottom: 4.5cm, top:4cm, left:4cm, right: 4cm),
  )
  // Cover page
  if titlepage {
    page(align(center + horizon, block(width: 90%)[
        #let v-space = v(2em, weak: true)
        #text(2em)[*#title*]

        #v-space 
        #for author in authors {
          text(1.1em, author)
          v(0.7em, weak: true)
        }
        
        #if date != none {
          v-space
          // Display date as MMMM DD, YYYY  
          text(1.1em, date.display(date-format))
        }
    ]))
  }
  //Paragraph properties
  set par(spacing: 0.7em, leading: 0.7em, justify: true, linebreaks: "optimized", first-line-indent: 1.2em)

  //Properties for all headings (incl. subheadings)
  set heading(numbering: "1.1")
  set heading(supplement: [Chapter ])
  show heading: set text(hyphenate: false)
  show heading: it => {
    v(2.5em, weak: true)
    it
    v(1.5em, weak: true)
  }
  show: front-matter

  // Properties for main headings (i.e "Chapters")
  show heading.where(level: 1): it => {
    //Show chapters only on odd pages:
    if chapters-on-odd {
      pagebreak(to: "odd", weak: false)
    } 
    else if chapter-pagebreak {
      //Show chapters on new page
      colbreak(weak: true)
    }
    //Display heading as two lines, a "Chapter # \n heading"
    v(10%)
    if it.numbering != none {
      set text(size: 20pt)
      set par(first-line-indent: 0em)
      
      text("Chapter ")
      numbering("1.1", ..counter(heading).at(it.location()))
    }
    v(1.4em, weak: true)
    set text(size: 24pt)
    block(it.body)
    v(1.8em, weak: true)
  }
  
  //Show abstract
  if abstract-en != none {
    page([
      = Abstract
      #abstract-en
    ])
  }
  //Show abstract
  if abstract-no != none {
    page([
      = Sammendrag
      #abstract-no
    ])
  }
  //Show preface
  if preface != none {
    page([
      = Preface
      #preface
    ])
  } 

  // Display table of contents.
  if table-of-contents != none {
    set par(leading: 10pt, justify: true, linebreaks: "optimized")

    show outline.entry.where(level: 1): it => {
      strong(it)
    }
    set outline(indent: true, depth: 3)
    table-of-contents
  }
  // Display list of figures
  if figure-index.enabled {
    outline(target: figure.where(kind: image), title: figure-index.title)
  }
  
  // Display list of tables
  if table-index.enabled {
    outline(target: figure.where(kind: table), title: table-index.title)
  }

  // Display list of code listings
  if listing-index.enabled {
    outline(target: figure.where(kind: raw), title: listing-index.title)
  }

  // Configure page numbering and footer.
  set page(
    header: context {
      // Get current page number.
      let i = counter(page).at(here()).first()

      // Align right for even pages and left for odd.
      let is-odd = calc.odd(i)
      let aln = if is-odd { right } else { left }

      // Are we on a page that starts a chapter?
      let target = heading.where(level: 1)
      

      // Find the chapter of the section we are currently in.
      let before = query(target.before(here()))
      if before.len() > 0 {
        let current = before.last()
        if query(target).any(it => it.location().page() == current.location().page() + 1) {
          return
        }
        let chapter_number = counter(heading).at(here()).first()
        if isappendix.get() {
          chapter_number = numbering("A.1", chapter_number)
        }
        let chapter = emph(text(size: 10pt, current.supplement + [ #chapter_number: ] + current.body))
        let display-title = []
        if short-title != [] {
          display-title = emph(text(size: 10pt, short-title))
        } else {
          display-title = emph(text(size: 10pt, title))
        }
        if short-author != none {
          display-title = emph(text(size: 10pt, short-author)) + [: ] + display-title
        }
        if current.numbering != none {
            if is-odd {
              grid(
                columns: (4fr, 1fr),
                align(left)[#chapter],
                align(right)[#i],
              )
            } else {
              grid(
                columns: (1fr, 4fr),
                align(left)[#i],
                align(right)[#display-title],
              )
            }
        }
      }
    },
    footer: ""
  )
  // Style code snippets
  // Display inline code in a small box that retains the correct baseline.
  show raw.where(block: false): box.with(
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt, 
  )

  // Display block code with padding.
  show raw.where(block: true): block.with(
    inset: (x: 5pt, y: 10pt),
    stroke: stroke-color,
    width: 100%,
  )
  show raw.where(block: true): set align(start)
  show figure.where(
    kind: raw
  ): set figure.caption(position: top)

  // Configure proper numbering of figures and equations.
  let numbering-fig = n => {
    let h1 = counter(heading).get().first()
    numbering("1.1", h1, n)
  }
  show figure: set figure(numbering: numbering-fig)
  let numbering-eq = n => {
    let h1 = counter(heading).get().first()
    numbering("(1.1)", h1, n)
  }
  set math.equation(numbering: numbering-eq)

  //Set table caption on top
  show figure.where(
    kind: table
  ): set figure.caption(position: top)
  
  //Style lists
  set enum(numbering: "1.a.i.", spacing: 0.8em, indent: 1.2em)
  set list(spacing: 0.8em, indent: 1.2em, marker: ([•], [◦], [--]))

  show: main-matter
  body
  
  //Style bibliography
  if bibliography != none {
    pagebreak()
    show std-bibliography: set text(0.95em)
    // Use default paragraph properties for bibliography.
    show std-bibliography: set par(leading: 0.65em, justify: false, linebreaks: auto)
    bibliography
  }
}


//Style appendix
#let appendix(chapters-on-odd: false, body) = {
  set heading(numbering: "A.1")
  set heading(supplement: [Appendix ])
  show heading: it => {
   if chapters-on-odd {
      pagebreak(to: "odd", weak: true)
    } else {
      colbreak(weak: true)
    }

    v(10%)
    if it.numbering != none {
      set text(size: 20pt)
      set par(first-line-indent: 0em)
      text("Appendix ")
      numbering("A.1", ..counter(heading).at(it.location()))
    }
    v(1.4em, weak: true)
    set text(size: 24pt)
    block(it.body)
    v(1.8em, weak: true)
  }
  // Reset heading counter
  counter(heading).update(0)
  
  // Equation numbering
  let numbering-eq = n => {
    let h1 = counter(heading).get().first()
    numbering("(A.1)", h1, n)
  }
  set math.equation(numbering: numbering-eq)
  
  // Figure and Table numbering
  let numbering-fig = n => {
    let h1 = counter(heading).get().first()
    numbering("A.1", h1, n)
  }
  show figure.where(kind: image): set figure(numbering: numbering-fig)
  show figure.where(kind: table): set figure(numbering: numbering-fig)
  
  isappendix.update(true)
    
  body
}
