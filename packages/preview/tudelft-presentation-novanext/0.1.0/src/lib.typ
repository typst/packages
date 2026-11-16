/* Package Entrypoint */

#import "@preview/polylux:0.4.0": slide, toolbox
#import "@preview/hydra:0.6.3": hydra, anchor
#import "@preview/tudelft-tools-novanext:0.1.0": *

#let footer-fill = state("footer-fill", (auto,))
#let set-footer-fill(..it) = {
  pagebreak(weak:true)
  footer-fill.update(it)
}


#let show-heading = e.element.declare(
  "show-heading",
  prefix: "@preview/tudelft-presentation-novanext,v0.1.0",
  doc: "Formats the section header",

  display: it => text(
  fill: tud-blue,
  size: 1.2em,
  weight: 700,
  font: it.font,
  context(hydra(
    display: (_, x) => {
      if it.numbering != none {
        if it.numbering == auto {
          counter(heading).display()
        } else {
          counter(heading).display(it.numbering)
        }
        " "
      }
      x.body
    }
  ))
),

  fields: (
    // Force this field to be specified.
    e.field("font", str, doc: "The font.", default: "Roboto Slab"),
    e.field("numbering", e.types.any, doc: "The numbering style.", default: auto),
  )
)

#let line-block(
  it,
  fill: tud-turquoise,
  stroke: tud-royal-blue
) = context(rect(
  fill: color.mix(fill, tud-blue),
  stroke: (right: 1em + stroke),
  width: 0.5 * page.width,
  // height: 0.2 * page.height,
  inset: 1em,
)[#align(center + horizon)[#it]])

#let list-marker(color: tud-blue, width: 0.3em, dy: 0.0em) = [#box(move(
  dy: dy,
  dx: 0em,
  square(
    width: width,
    fill: color,
)))]

#let section-header = e.element.declare(
  "section-header",
  prefix: "@preview/tudelft-presentation-novanext,v0.1.0",
  doc: "Formats the section header",

  display: it => {
    let s = str(it.number)
    
    text(
      font: it.number-font,
      size: 2em,
      weight: it.number-weight,
      fill:white,
      if s.match(regex("^\\d$")) !=none
        {[0] + s} else {s}
    )
    v(-.4em)
    line(length: 4em, stroke: white)
    it.body
  },

  fields: (
    // Force this field to be specified.
    e.field("number", str, required: true),
    e.field("body", content, required: true),
    e.field("number-weight", e.types.any, default: 500),
    e.field("number-font", str, doc: "The font.", default: "Roboto Slab"),
  )
)

#let tud-presentation(it) = {
  show: set-fonts
  set text(size: 25pt)

  show title: set text(font: "Roboto Slab")

  set heading(numbering: "1.1")
  // hide sectioning
  show heading.where(level: 3): it => []
  show heading.where(level: 2): it => []

show heading.where(level: 1): it => {
  pagebreak(weak: true)
  slide({
    align(center + bottom, {
      move(
        dy: page.height - 5em,
        box(fill:white, height:5em, width: page.width))
      v(-page.height)
      v(1fr)
      line-block(text(fill:white,
        context {
          let selector = selector(heading).before(here())
          let level = counter(selector)
          section-header(
            counter(heading).display(),
            it.body,
          )
        }
      ))
    })
  })
  pagebreak(weak: true)
}

  set enum(numbering: "a.1.i.")
  show enum: set text(tud-blue, font: "Roboto Slab", weight: 500)
  show enum.item: set text(black, font: "Arial", weight: "regular")
  set list(marker: list-marker())

  set page(
    paper: "presentation-16-9",
    margin: 2cm,
    header: anchor(),
    footer: align(bottom, context({
      let fill0 = footer-fill.get().at(0)
      let fill1 = footer-fill.get().at(1, default: fill0)
      let fill2 = footer-fill.get().at(2, default: fill0)
      if fill0 == none {
      } else if fill0 == auto {
        tud-logo(full: false)
      } else {
        tud-logo(full: false,
          fill: fill0,
          U: fill2,
        )
      }
      h(1fr)
      if fill1 == none {
      } else {
        text(
          fill: if fill1 == auto {gray} else {fill1},
          size: 0.7em,
          {
            document.date.display("[year]-[month padding:zero]-[day padding:zero]")
            h(2em)
            toolbox.slide-number
          }
        )
      }
      v(1em)
    }))
  )

  // Bold titles.
  show table.cell.where(x: 0): set text(weight: "bold", fill: tud-blue)

  // Medium bold table header.
  show table.cell.where(y: 0): set text(weight: "bold", fill: white)

  set table(
    fill: (_, y) => if calc.even(y) { if y == 0{tud-blue} else {silver }},
    stroke: none,
    inset: .4em,
  )

  show footnote.entry: it => {
    let loc = it.note.location()
    grid(
      columns: (1.5em, 1fr), // Column 1: number width, Column 2: text
      align: (right, left),
      super(numbering("1 ", ..counter(footnote).at(loc))),
      it.note.body
    )
  }

  it
}

#let tud-presentation-classic(it) = {
  show: tud-presentation
  show: set-fonts-classic
  show title: set text(
    font: "Libertinus Serif",
    weight: 600,
  )
  show enum: set text(font: "Libertinus Serif", weight: "bold")
  show enum.item: set text(font: "Libertinus Serif", weight: "regular")
  show: e.set_(section-header,
    number-font: "Libertinus Serif",
    number-weight: 600,
  )
  show: e.set_(show-heading,
    font: "Libertinus Serif",
  )
  show: e.set_(if-classic-else,
    is-classic: true,
  )
  it
}
