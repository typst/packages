
#import "@preview/hydra:0.6.2": hydra
#import "@preview/showybox:2.0.4": *
#import "../bookly-helper.typ": *
#import "../bookly-defaults.typ": *

#let classic(colors: default-colors, it) = {
  states.theme.update("classic")

  // Headings
  show heading.where(level: 1): it => {
    // Reset counters
    reset-counters

    // Heading style
    place(top)[
      #rect(fill: white, width: 1%, height: 1%)
    ]
    set align(left)
    let type-chapter = if states.isappendix.get() {states.localization.get().appendix} else {states.localization.get().chapter}
    if it.numbering != none {
      v(4em)
      block[
        #text(size: 1.5em)[#type-chapter #counter(heading).display(states.num-heading.get())]

        #text(2em)[#it.body]
      ]
      v(3em)
    } else {
      v(1em)
      text(2em)[#it.body]
      v(2em)
    }
  }

  show heading.where(level: 2): it => {
    block(above: 2em, below: 1.25em)[
      #it
    ]
  }

  show heading.where(level: 3): it => {
    block(above: 1.25em, below: 1.25em)[
      #it
    ]
  }

  // Tables
  show table.cell.where(y: 0): set text(weight: "bold")
  set table(
    stroke: (_, y) => (
      top: if y <= 1 {0.75pt} else {0pt},
      bottom: 0.75pt
    ),
  )

  // Outline
  set outline.entry(fill: box(width: 1fr, repeat(gap: 0.25em)[.]))
  show outline.entry: it => {
    show linebreak: none
    if it.element.func() == heading {
      let number = it.prefix()
      let section = it.element.body
      let item = none
      if it.level == 1 {
        block(above: 1.25em, below: 0em)
        v(0.5em)
        item = [*#number #it.inner()*]
      } else if it.level == 2 {
        block(above: 1em, below: 0em)
        item = [#h(1em) #number #it.inner()]
      } else {
        block(above: 1em, below: 0em)
        item = [#h(2em) #number #it.inner()]
      }
      link(it.element.location(), item)
    } else if it.element.func() == figure {
      block(above: 1.25em, below: 0em)
      v(0.25em)
      link(it.element.location(), [#it.prefix(). #h(0.2em) #it.inner()])
    } else {
      it
    }
  }

  // Page style
  let page-header = context {
    show linebreak: none
    show: fullwidth
    if calc.odd(here().page()) {
      align(left, hydra(2, display: (_, it) => [
      #let head = none
      #if it.numbering != none {
        head = numbering(it.numbering, ..counter(heading).at(it.location())) + " " + it.body
      } else {
        head = it.body
      }
      #head
      #place(dx: 0%, dy: 52%)[#line(length: 100%, stroke: 0.75pt)]
    ]))
    } else {
      align(left, hydra(1, display: (_, it) => [
      #let head = counter(heading.where(level:1)).display() + " " + it.body
      #if it.numbering == none {
        head = it.body
      }
      #head
      #place(dx: 0%, dy: 50%)[#line(length: 100%, stroke: 0.75pt)]
    ]))
    }
  }

  let page-footer = context {
    let cp = counter(page).get().first()
    let current-page = counter(page).display()
    let dx = 0%
    if states.tufte.get() {
      dx = 21.65%
    }
    set align(center)
    move(dx: dx, current-page)
  }

  set page(
    paper: paper-size,
    header: page-header,
    footer: page-footer
  )

  it
}

// Boxes - Definitions
#let custom-box-classic(title: none, icon: "info", color: rgb(29, 144, 208), body) = {
  showybox(
    title: box-title(color-svg("resources/images/icons/" + icon + ".svg", white, width: 1em), [*#title*]),
    title-style: (
      boxed-style: (
        anchor: (x: left, y: horizon),
        offset: (x: -1em, y: 1.15em),
        radius: (top-left: 0pt, top-right: 0pt, bottom-left: 0pt, bottom-right: 5pt)
      )
    ),
    frame: (
      title-color: color,
      border-color: color,
      body-color: color.lighten(90%),
      thickness: 2pt,
      body-inset: (top:2em, left: 1em, right: 1em, bottom: 1em)
    ),
    align: center,
    breakable: true
  )[#body]
}

// Part
#let part-classic(title) = context {
  states.counter-part.update(i => i + 1)
  set page(
    header: none,
    footer: none,
    numbering: none
  )

  set align(center + horizon)

  pagebreak(weak: true, to:"odd")

  let dx = 0%
  if states.tufte.get() {
    dx = 21.68%
  }

  move(dx: dx)[
    #text(size: 2.5em)[#states.localization.get().part #states.counter-part.display(states.part-numbering.get())]
    #v(1em)
    #text(size: 3em)[*#title*]
  ]

  show heading: none
  heading(numbering: none)[
    #v(1em)
    #box[#states.localization.get().part #states.counter-part.display(states.part-numbering.get()) -- #title]
  ]

  pagebreak(weak: true, to:"odd")
}

#let minitoc-classic = context {
  let toc-header = states.localization.get().toc
  block(above: 3.5em)[
    #text([*#toc-header*])
    #v(-0.5em)
  ]

  let miniline = line(stroke: 0.75pt, length: 100%)

  miniline
  v(0.5em)
  suboutline(target: heading.where(outlined: true, level: 2))
  miniline
}

