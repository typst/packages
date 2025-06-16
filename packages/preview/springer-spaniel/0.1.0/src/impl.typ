
#import "package/ctheorems.typ": thmrules
#import "package/gentle-clues.typ": gentle-clues
#import "@preview/chromo:0.1.0": square-printer-test, gradient-printer-test, circular-printer-test, crosshair-printer-test
#import "package/drafting.typ" as drafting
#import "package/codly.typ" as codly

#let template(
  title: [Contribution Title],
  authors: (),
  abstract: none,
  debug: false,
  printer-test: false,
  frame: none
) = (body) => {

  // --------------------------------------------------------------------------
  // Debug option
  show: (it)=>{
    if (debug){
      show v: (it)=>{
        place(box(width: 1pt, it, stroke: olive))
        place(dx: 0.5em, text(size: 7pt, fill: olive, repr(it)))
        it
      }
      // show place: set block(fill: luma(95%))
      set page(background: {
        place(
          dx: 5cm,
          dy: 5cm,
          {
            rect(
              width: 100% - 10cm,
              height: 100% - 11.25cm,
              stroke: 0.1pt
            )
          }
        )
      })
      show link: set text(stroke: eastern)
      show cite: set text(stroke: eastern)
      show ref: set text(stroke: eastern)
      show footnote: box.with(stroke: eastern)
      show math.equation.where(block: true): block.with(stroke: olive)
      // show box: set box(stroke: 1pt + olive)
      // show block: set block(stroke: 1pt + olive)
      it
    } else {
      it
    }
  }

  // --------------------------------------------------------------------------
  // Text
  set text(size: 9pt, weight: 450)
  set block(spacing: 1em)
  set par(justify: true, first-line-indent: 1.5em)
  show par: set block(spacing: 0.65em)
  show par: set align(left)

  // --------------------------------------------------------------------------
  // Page
  set page(margin: (x:5cm, top:5cm, bottom: 6.25cm))
  set page(header-ascent: 1.5em)
  set page(
    header: context{
      set text(size: 7pt)
      if debug {
        place(
          rect(width: 100%, height: 100%, stroke: 0.1pt)
        )
      }
      if here().page() > 1 {
        if (calc.even(here().page())){
          text[#here().page()]
          h(1fr)
          authors.map(it=>it.name).join(", ", last: " and ")
        } else {
          text(title)
          h(1fr)
          text[#here().page()]
        }
      }
    },
    footer: if debug {
      place(
        rect(width: 100%, height: 100%, stroke: 0.1pt)
      )
    },
    background: {
      if (frame != none){
        place(rect(width: 100%, height: 100%, stroke: frame))
      }
      if debug {
        place(dy: 5cm, rect(width: 4.5cm, height: 100% - 11.25cm, stroke: 0.1pt))
        place(dy: 5cm, right, rect(width: 4.5cm, height: 100% - 11.25cm, stroke: 0.1pt))
        place(dy: 5cm, dx: 5cm, rect(width: 100%-10cm, height: 100% - 11.25cm, stroke: 0.1pt))
      }
    },
    foreground: if printer-test {
      place(right, pad(1cm,square-printer-test(size: 1em)))
      place(left , pad(1cm,gradient-printer-test()))

      place(right+bottom, pad(1cm,circular-printer-test(size: 2cm)))
      place(left+bottom , pad(1cm,crosshair-printer-test(size: 1em)))
    }
  )
  
  // --------------------------------------------------------------------------
  // Headings
  set heading(numbering: "1.1", offset: 0)
  show heading: set block(above: 3em, spacing: 1.5em)
  show heading.where(level: 4): set block(above: 1.5em, below: 1em)
  show heading.where(level:4): set text(weight: 450)
  show heading.where(level: 4): set heading(numbering: none, outlined: false)
  show heading.where(level: 5): set block(above: 1.5em, below: 1em)
  show heading.where(level: 5): set text(weight: 450, style: "italic")
  show heading.where(level: 5): set heading(numbering: none, outlined: false)
  set heading(supplement: [Sect.])

  // --------------------------------------------------------------------------
  // Mathematics
  set math.equation(numbering: "(1)")
  show math.equation: set block(spacing: 1.5em)

  // --------------------------------------------------------------------------
  // Footnotes
  set footnote.entry(
    indent: 0em, 
    separator: line(length: 25%, stroke: 0.75pt), 
    // gap: 0.65em
  )
  show footnote.entry: set text(7.25pt)

  // --------------------------------------------------------------------------
  // Figures
  set figure(supplement: [Fig.])
  set figure(placement: auto, gap: 1em)
  show figure.caption: set text(size: 8pt)
  show figure.where(placement: auto): set place(clearance: 1.5em)
  show figure.where(kind: table): set figure(supplement: [Table])
  
  set figure.caption(position: bottom)
  show figure.where(kind: table): set figure.caption(position: top)
  // show figure.caption: set align(left)
  show figure.caption: set par(first-line-indent: 0em)
  // show figure: set align(left)
  // show figure.caption: (it) => [
  //   *#it.supplement #it.counter.display()*#it.separator;#it.body
  // ]
  
  show table: set text(size: 8pt)

  // --------------------------------------------------------------------------
  // Lists
  show enum: set block(spacing: 1.5em)
  show list: set block(spacing: 1.5em)

  // --------------------------------------------------------------------------
  // Bibliography
  set bibliography(style: "springer-mathphys")
  show bibliography: set par(first-line-indent: 0em)
  show bibliography: set block(spacing: 1em)
  show bibliography: it=> {
    show heading: set block(above: 3em, below: 1.5em)
    it
  }

  // --------------------------------------------------------------------------
  // Packages
  show: thmrules
  show: gentle-clues
  place(drafting.set-page-properties())
  show: codly.codly-init.with()
   
  // --------------------------------------------------------------------------
  // Title
  v(2cm)
  { 
    set text(weight: "black", size: 16pt)
    block(title)
  }
  v(0.5cm)
  {
    block(text(authors.map(it=>it.name).join(", ", last: " and ")))
  }
  v(3.5cm)
  // --------------------------------------------------------------------------
  // Main body
  place(
    float: true,
    bottom,
    {
      set text(size: 7.5pt)
      set par(first-line-indent: 0em)
      line(length: 25%, stroke: 0.75pt)
      show par: set block(below: 1.5em)

      authors.map(
        (it)=>{
          it.name
          linebreak()
          [#it.institute, #it.address, email: #link("mailto:" + it.email)]
        }
      ).join(parbreak())
    }
  )

  if (abstract != none){
    strong({
      [Abstract]
      h(0.25em)
      sym.dash.em
    })
    h(weak: true, 0.25em)
    abstract
  }

  
  body
  // --------------------------------------------------------------------------

}

