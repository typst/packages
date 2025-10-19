#import "@preview/hydra:0.6.2": hydra
#import "../bookly-helper.typ": *
#import "../bookly-defaults.typ": *

#let modern(colors: default-colors, it) = {
    states.theme.update("modern")

    // Headings
    show heading.where(level: 1): it => context {
      // Reset counters
      reset-counters

      // Heading style
      let type-chapter = if states.isappendix.get() {states.localization.get().appendix} else {states.localization.get().chapter}

      let dxr = 0%
      let dxb = 0%
      let dxc = 0%
      if states.tufte.get() {
        dxr = 12.5%
        dxb = 35.2%
        dxc = 8.2%
      }

      if it.numbering != none {
        place(top, dx: -16%, dy: - 11%)[
          #fullwidth[#rect(fill: gradient.linear(colors.primary, colors.primary.transparentize(65%), dir: ltr), width: 132% - dxr, height: 35%)]
        ]

        place(top, dx: dxc, dy: 10%)[
          #text(size: 2.5em, fill: white)[#type-chapter #counter(heading).display(states.num-heading.get())]
        ]

        place(right, dx: dxb, dy: 22.75%)[
          #box(outset: 0.9em, radius: 5em, stroke: none, fill: states.colors.get().primary)[#text(size: 1.5em, fill: white)[#it.body]]
        ]
        v(15em)
      } else {
        place(top, dx: -16%, dy: -11%)[
          #fullwidth[#rect(fill: gradient.linear(colors.primary, colors.primary.transparentize(65%), dir: ltr), width: 132% - dxr, height: 10%)]
        ]

        place(top + right, dx: dxb, dy: -2.25%)[
          #box(outset: 0.9em, radius: 5em, stroke: none, fill: colors.primary)[#text(size: 1.5em, fill: white)[#it.body]]
        ]

        v(3em)
    }
  }

  show heading.where(level: 2): it => {
    block(above: 1.5em)[
      #if it.numbering != none {
        text(counter(heading).display(), fill: colors.primary)
        h(0.25em)
      }
      #text(it.body)
      #v(-0.75em)
      #line(stroke: 0.75pt + colors.primary, length: 100%)
      #v(0.75em)
    ]
  }

  show heading.where(level: 3): it => {
    block[
      #if it.numbering != none {
        text(counter(heading).display(), fill: colors.primary)
        h(0.25em)
      }
      #text(it.body)
      #v(1em)
    ]
  }

  // Tables
  show table.cell.where(y: 0): set text(weight: "bold", fill: white)
  set table(
    fill: (_, y) => if y == 0 {colors.primary} else if calc.odd(y) {colors.secondary.lighten(60%)},
    stroke: none
  )

  // Footnotes
  set footnote.entry(separator: line(length: 30% + 0pt, stroke: 0.75pt + colors.primary))

  // References
  show ref: set text(fill: colors.primary)

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
        item = [#text([*#number*], fill: colors.primary) *#it.inner()*]
      } else if it.level == 2{
        block(above: 1em, below: 0em)
        item = [#h(1em) #text([#number], fill: colors.primary) #it.inner()]
      } else {
        block(above: 1em, below: 0em)
        item = [#h(2em) #text([#number], fill: colors.primary) #it.inner()]
      }
      link(it.element.location(), item)
    } else if it.element.func() == figure {
      block(above: 1.25em, below: 0em)
      v(0.25em)
      link(it.element.location(), [#text([#it.prefix().], fill: colors.primary) #h(0.2em) #it.inner()])
    } else {
      it
    }
  }

  // Page style
  let page-header = context {
    show linebreak: none
    show: fullwidth
    set text(style: "italic", fill: colors.header)
      if calc.odd(here().page()) {
        align(right)[
          #hydra(2, display: (_, it) => [
            #let head = none
            #if it.numbering != none {
              head = numbering(it.numbering, ..counter(heading).at(it.location())) + " " + it.body
            } else {
              head = it.body
            }
            #let size = measure(head)
            #head
            #place(dx: -16%, dy: -40%)[#line(length: 115% - size.width, stroke: 0.5pt + colors.primary)]
            #place(dx: 98.5% - size.width, dy: -75%)[#circle(fill: colors.primary, stroke: none, radius: 0.25em)]
          ])
        ]
      } else {
      align(left)[
        #hydra(1, display: (_, it) => [
          #let head = counter(heading.where(level:1)).display() + " " + it.body
          #if it.numbering == none {
            head = it.body
          }
          #let size = measure(head)
          #head
          #place(dx: size.width + 1%, dy: -40%)[#line(length: 115%, stroke: 0.5pt + colors.primary)]
          #place(dx: size.width, dy: -75%)[#circle(fill: colors.primary, stroke: none, radius: 0.25em)]
          ]
        )
      ]
    }
  }

  let page-footer = context {
    let cp = counter(page).get().first()
    let current-page = counter(page).display()
    show: fullwidth
    set text(fill: white, weight: "bold")
    v(1.5em)
    if calc.odd(cp) {
      set align(right)
      box(outset: 6pt, fill: colors.primary, width: 1.5em, height: 100%)[
        #set align(center)
        #current-page
      ]
    } else {
      let dx = 0%
      if states.tufte.get() {
        dx = 8.2%
      }
      set align(left)
      box(outset: 6pt, fill: colors.primary, width: 1.5em, height: 100%)[
        #set align(center)
        #current-page
      ]
    }
  }

  set page(
    paper: paper-size,
    header: page-header,
    footer: page-footer
  )

  it
}

// Boxes - Definitions
#let custom-box-modern(title: none, icon: "info", color: rgb(29, 144, 208), body) = {
  grid(
    columns: (auto, 1fr),
    column-gutter: 0.75em,
    align: top + left,
    [
      #v(0.5em)
      #color-svg("resources/images/icons/" + icon + ".svg", color, width: 1.5em)
    ],
    [
      #box(
      stroke: (left: 1.25pt + color),
      fill: color.lighten(90%),
      inset: 1em,
      width: 100%
      )[#body]
    ]
  )
}

// Part
#let part-modern(title) = context {
  states.counter-part.update(i => i + 1)
  set page(
    header: none,
    footer: none,
    numbering: none
  )

  set align(center + horizon)

  pagebreak(weak: true, to:"odd")

  let dxr = 0%
  let dxb = 0%
  if states.tufte.get() {
    dxr = 21.68%
    dxb = 36%
  }

  place(top + center, dx: dxr, dy: -11%)[
    #fullwidth[#rect(fill: gradient.linear(states.colors.get().primary, states.colors.get().primary.transparentize(55%), dir: ttb), height: 61%, width: 135% + dxr)[
      #set align(center + horizon)

      #text(size: 5em, fill: white)[*#states.localization.get().part #states.counter-part.display(states.part-numbering.get())*]
    ]]
  ]

  place(center + horizon, dx: dxr)[
    #box(outset: 1.25em, stroke: none, radius: 5em, fill: states.colors.get().primary)[
      #set text(fill: white, weight: "bold", size: 3em)
      #title
    ]
  ]

  show heading: none
  heading(numbering: none)[
    #v(1em)
    #box[#states.localization.get().part #states.counter-part.display(states.part-numbering.get()) -- #title]
  ]

  pagebreak(weak: true, to:"odd")
}

#let minitoc-modern = context {
  let toc-header = states.localization.get().toc
  block(above: 3.5em)[
    #text([*#toc-header*])
    #v(-0.5em)
  ]

  let miniline = line(stroke: 0.75pt + states.colors.get().primary, length: 100%)

  miniline
  v(0.5em)
  suboutline(target: heading.where(outlined: true, level: 2))
  miniline
}

