#import "@preview/subpar:0.2.2"
#import "@preview/hydra:0.6.2": hydra

#let in-outline = state("in-outline", false)

//custom caption function to show the short version in the outline and the long version in the figure
#let caption(short, details) = context {
  if in-outline.get() {
    short
  } else {
    [#strong(short). #details]
  }
}

// todo helper
#let todo(stuff) = text(weight: "bold", fill: red, [TODO: ] + stuff)

// numbered subfigure grid
#let subfig-grid(..args) = subpar.grid(
  align: top + start,
  numbering-sub: "A",
  numbering-sub-ref: (..nums) => numbering("1A", ..nums),
  show-sub-caption: (num, it) => {
    set text(size: 1.5em) //big numeration
    // subcaption numbering
    text(weight: "bold", num)
    // it.separator
    // subcaption body
    it.body
  },
  show-sub: it => {
    set figure.caption(position: top)
    it
  },
  ..args,
)

//numbered subfigure grid, special attachment numbering
#let subfig-grid-attachments(..args) = subpar.grid(
  align: top + start,
  numbering-sub: "A",
  numbering-sub-ref: (..nums) => numbering("S1A", ..nums),
  show-sub-caption: (num, it) => {
    set text(size: 1.5em) //big numeration
    // subcaption numbering
    text(weight: "bold", num)
    // it.separator
    // subcaption body
    it.body
  },
  show-sub: it => {
    set figure.caption(position: top)
    it
  },
  ..args,
)

// shorthand for the upright mu letter
#let upmu = [~$upright(mu)$]

//--------------Function to show outline, list of figures, list of tables and list of abbreviations
#let outlines = {
  //----Table of Contents
  //heading level 1 bold
  page(numbering: "I")[
    #show outline.entry.where(level: 1): it => {
      set text(1.2em, weight: "bold")
      v(1.5em, weak: true)
      it
    }

    #heading([Table of Contents], numbering: none, outlined: false)
    #v(0.5em)
    #outline(title: none, depth: 3)
  ]
  pagebreak()

  // ONLY SHOW SHORT CAPTION IN OUTLINE
  show outline: it => {
    in-outline.update(true)
    it
    in-outline.update(false)
  }

  show outline.entry: it => link(
    it.element.location(),
    it.indented(strong(it.prefix()), it.inner()),
  )

  //---------List of Images
  page(numbering: "I")[
    #heading([List of Images], numbering: none)
    #v(0.5em)
    #outline(title: none, target: figure.where(kind: image))
  ]
  pagebreak()

  //---------List of Tables
  page(numbering: "I")[
    #heading([List of Tables], numbering: none)
    #v(0.5em)
    #outline(title: none, target: figure.where(kind: table))
  ]
  pagebreak()

  show link: it => strong(text(blue, it))
}

//==========================Header design=========================
#let page-header = {
  set page(
    header: [
      #set text(size: 12pt)
      //displayed smart heading level one im document header
      #context { strong(hydra(1, skip-starting: false, use-last: true)) }
      #h(1fr)
      #context { strong(counter(page).display()) }
      #v(-0.9em) #line(length: 100%)
    ],
  )
}

// ===========================Template================================
#let template = {
  [

//=========================Page formatting============================
#set page(
  margin: (x: 2.5cm, y: 2.5cm),
  paper: "a4",
)

// blocksatz
#set par(justify: true, linebreaks: "optimized")

#set heading(numbering: "1.1.1.a.")

#set text(
  font: "TeX Gyre Heros", //Helvetica
  lang: "en",
  hyphenate: true,
  size: 12pt,
  ligatures: false,
  region: "US",
)

//===================show rules================================

#show heading: it => text(hyphenate: false, it)

//figure caption left-aligned
#show figure.caption: set align(start)

//figure supplement bold, text 10pt
#show figure.caption: it => context box(
  inset: (left: 1.4em, right: 1.4em),
  align(left)[#text(size: 10pt)[
    *#it.supplement~#it.counter.display()#it.separator*#it.body
  ]],
)
#set image(fit: "contain", scaling: "smooth")

#show figure.where(kind: image): set text(size: 10pt)

//-------------------------table design-----------------------
#show table.cell.where(y: 0): strong //first table line *bold*
#set table(
  stroke: (x, y) => (
    left: if x > 0 { 0.7pt },
    top: if y == 0 { 1.0pt },
    bottom: if y == 0 { 0.7pt },
  ),
  align: (x, y) => center + horizon,
)
#set table.hline(stroke: 0.7pt)
//caption above table
#show figure.where(kind: table): set figure.caption(position: top)

// -------------------------------------------------------------

// footnotes definieren
#set footnote.entry(gap: 0.6em, indent: 0em)

// references bold and blue
#show ref: it => strong(text(fill: blue, it))
#show link: set text(hyphenate: false)
#show cite: it => strong(text(fill: blue, it))

#show bibliography: it => {
  show link: set text(blue)
  show link: strong
  set text(size: 10pt, costs: (hyphenation: 150%))
  columns(it)
}

#show math.equation: set text(font: "Lete Sans Math")

#set pagebreak(weak: true)

  ]
}
