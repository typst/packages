
// Typst ACL style - https://github.com/coli-saar/tracl
// by Alexander Koller <koller@coli.uni-saarland.de>

// 2025-03-28 v0.6.0 - improved lists and line numbers
// 2025-03-28 v0.5.2 - bumped blinky dependency to 0.2.0
// 2025-03-02 v0.5.1 - fixed font names so as not to overwrite existing Typst symbols
// 2025-02-28 v0.5.0 - adapted to Typst 0.13, released to Typst Universe
// 2025-02-18 v0.4, many small changes and cleanup, and switch to Nimbus fonts
// v0.3.2, ensure page numbers are printed only in anonymous version
// v0.3.1, fixed "locate" deprecation
// v0.3, adjusted some formatting to the ACL style rules
// v0.2, adapted to Typst 0.12

#import "@preview/oxifmt:0.2.1": strfmt

// "Times" in Tex Live is actually Nimbus Roman
#let tracl-serif = ("Nimbus Roman No9 L", "Libertinus Serif")  
#let tracl-sans = ("Nimbus Sans L", "Helvetica")
#let tracl-mono = ("Inconsolata", "DejaVu Sans Mono")

#let linespacing = 0.55em

#let maketitle(title:none, authors:none, anonymous:false) = place(
  top + center, scope: "parent", float: true)[
    #box(height: 5cm, width: 1fr)[
      #align(center)[
        #text(15pt, font: tracl-serif)[#par(leading:0.5em)[
          *#title*
        ]]
        #v(2.5em)
      
        #if anonymous {
          set text(12pt)
          [*Anonymous ACL submission*]
        } else {
          set text(12pt)
          set par(leading: 0.5em)
          let count = authors.len()
          let ncols = calc.min(count, 3)
          grid(
            columns: (1fr,) * ncols,
            row-gutter: 24pt,
            ..authors.map(author => [
              *#author.name* \
              #author.affiliation \
              #text(font: tracl-mono, 11pt)[#link("mailto:" + author.email)]
            ]),
          )  
        }
        #v(1em)
      ]      
    ]
  ]


#let darkblue = rgb("000099")
#let sidenumgray = rgb("bfbfbf")

#show link: it => text(blue)[#it]


#let abstract(abs) = [
  #set par(leading: linespacing, first-line-indent: 0em, justify: true)
  #align(center, 
    box(width: 90%,[
      #text(12pt)[*Abstract*]
      #v(0.8em)
      #text(10pt, align(left, abs))
    ])
  )]

// typeset a line number
#let sidenum(i) = {
  let s = str(i)
  while s.len() < 3 {
    s = "0" + s
  }
  text(font: tracl-sans, 7pt, fill: sidenumgray)[#s]
}


// citation commands
#let citet(x) = cite(x, form: "prose")
#let citep(x) = cite(x)
#let citealp(x) = [#cite(x, form: "author"), #cite(x, form: "year")]
#let citeposs(x) = [#cite(x, form: "author")'s (#cite(x, form: "year"))]

// Switch to appendix. By default, the appendices start on a fresh page.
// If you don't want this, pass "clearpage: false".
#let appendix(content, clearpage: true) = {
  if( clearpage ) { pagebreak() }

  set heading(numbering: "A.1", supplement: "Appendix")
  counter(heading).update(0)

  content
}





#let acl(doc, title:none, authors: none, anonymous: false) = {
  // overall page setup
  let page-numbering = if anonymous { "1" } else { none } // number pages only if anonymous
  set page(paper: "a4", margin: (x: 2.5cm, y: 2.5cm), columns: 2, numbering: page-numbering)
  set columns(gutter: 6mm)
  
  // some colors
  show link: it => text(darkblue)[#it]
  show cite: it => text(darkblue)[#it]
  show ref: it => text(darkblue)[#it] // TODO - this makes all of "Section 6" blue; instead, make only the 6 blue

  // font sizes
  set text(11pt, font: tracl-serif)
  set par(leading: linespacing, first-line-indent: 4mm, justify: true, spacing: linespacing)

  show figure.caption: set text(10pt, font: tracl-serif)
  show figure.caption: set align(left)
  show figure.caption: it => [#v(0.5em) #it]

  show footnote.entry: set text(9pt, font: tracl-serif)

  show raw: set text(10pt, font: tracl-mono)

  // headings
  set heading(numbering: "1.1")

  let sectionheading(title) = {
    v(1.2em, weak: true)
    text(12pt, font: tracl-serif)[#title]
    v(1em, weak: true)
  }

  show heading.where(level:1): it => sectionheading(it)

  show heading.where(level:2): it => {
    // This is better than it was, but = followed by ==
    // is still too wide a gap - get rid of it manually with v(-0.5em) if needed
    v(1.5em, weak: true)
    text(11pt, font: tracl-serif)[#it]
    v(1em, weak: true)
  }

  // lists and enums
  set list(marker: text(7pt, baseline: 0.2em)[●], indent: 1em)
  show list: set par(spacing: 1em)

  set enum(indent: 1em)
  show enum: set par(spacing: 1em)

  // spacing around figures
  // show figure: set block(inset: (top: 0pt, bottom: 1cm))

  // bibliography
  show bibliography: it => {
    set text(size: 10pt)
    set par(leading: linespacing, first-line-indent: 0mm, hanging-indent: 4mm, justify: true, spacing: 1em)
    show heading: it => sectionheading("References")
    it
  }

  // if anonymous, add line numbering to every page
  // by executing it in the header
  if anonymous {
    set par.line(numbering: "001", number-clearance: 4em)
    set par.line(
      numbering: n => text(sidenumgray, font: tracl-sans, size: 8pt)[
        *#strfmt("{:03}", n)*
      ]
    )
    show figure: set par.line(numbering: none) // Disable numbers inside figures.

    maketitle(title:title, authors:authors, anonymous:anonymous)    
    doc 
  } else {
    maketitle(title:title, authors:authors, anonymous:anonymous)    
    doc 
  }

  // TODO: play around with these costs to optimize the layout in the end
  // set text(costs: (orphan: 0%, widow: 0%))

  
}



