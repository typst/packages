#import "@preview/showybox:2.0.4": *
#import "bookly-defaults.typ": *
#import "bookly-helper.typ": *

// Boxes - Utility
#let box-title(a, b) = {
  grid(columns: 2, column-gutter: 0.5em, align: (horizon),
    a,
    b
  )
}

#let colorize(svg, color) = {
  let blk = black.to-hex();
  if svg.contains(blk) {
    svg.replace(blk, color.to-hex())
  } else {
    svg.replace("<svg ", "<svg fill=\""+ color.to-hex() + "\" ")
  }
}

#let color-svg(
  path,
  color,
  ..args,
) = {
  let data = colorize(read(path), color)
  return image(bytes(data), ..args)
}

// Boxes - Definition
#let custom-box(title: none, icon: "info", color: rgb(29, 144, 208), body) =  context if states.theme.get().contains("fancy") or states.theme.get().contains("modern") {
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
} else if states.theme.get().contains("classic") {
   showybox(
    title: box-title(color-svg("resources/images/icons/" + icon + ".svg", color, width: 1em), [*#title*]),
    title-style: (
      color: color,
      sep-thickness: 0pt,
    ),
    frame: (
      title-color: color.lighten(85%),
      border-color: color,
      body-color: none,
      thickness: (left: 1.25pt),
      radius: 0pt,
    ),
    breakable: true
  )[#body]
}

// Information box
#let info-box = custom-box.with(title: context states.localization.get().note)

// Tip box
#let tip-box = custom-box.with(title: context states.localization.get().tip, icon: "tip", color: rgb(0, 166, 81))

// Warning box
#let warning-box = custom-box.with(title: context states.localization.get().warning, icon: "alert", color: orange)

// Important box
#let important-box = custom-box.with(title: "Important", icon: "stop", color: rgb("#f74242"))

// Proof box
#let proof-box = custom-box.with(title: context states.localization.get().proof, icon: "report", color: eastern)

// Question box
#let question-box = custom-box.with(title: "Question", icon: "question", color: purple)

// Headings
#let headings-on-odd-page(it) = {
  show heading.where(level: 1): it => {
    {
      set page(header: none, footer: none)
      pagebreak(to: "odd")
    }
    it
  }
  it
}

#let heading-level1(it) = {
  show heading.where(level: 1): it => {
    counter(math.equation).update(0)
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    if states.layout.get().contains("tufte"){
      states.sidenotecounter.update(0)
    }
    counter(footnote).update(0)

    if states.theme.get().contains("fancy") {
      place(top)[
        #rect(fill: white, width: 1%, height: 1%)
      ]
      set align(right)
      set underline(stroke: 2pt + states.colors.get().secondary, offset: 8pt)
      let dx = 0%
      if states.layout.get().contains("tufte") {
        dx = 35.2%
      }
      show: move.with(dx: dx)
      if it.numbering != none {
        v(5em)
        block[
          #text(counter(heading).display(states.num-heading.get()), size: 4em, fill: states.colors.get().primary)
          #v(-3em)
          #text(underline(it.body), size: 1.5em)
        ]
        v(5em)
      } else {
        v(1em)
        text(underline(it.body), size: 1.5em)
        v(2.5em)
      }
    } else if states.theme.get().contains("classic") {
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
        v(1em)
      }
    } else if states.theme.get().contains("modern") {
      let type-chapter = if states.isappendix.get() {states.localization.get().appendix} else {states.localization.get().chapter}

      let dxr = 0%
      if states.layout.get().contains("tufte") {
        dxr = 4%
      }

      let dxb = 0%
      if states.layout.get().contains("tufte") {
        dxb = 35.2%
      }

      if it.numbering != none {
        place(top, dx: -16% + dxr, dy: - 11%)[
          #fullwidth[#rect(fill: gradient.linear(states.colors.get().primary, states.colors.get().primary.transparentize(65%), dir: ltr), width: 132% +dxr, height: 35%)]
        ]

        let dxc = 0%
        if states.layout.get().contains("tufte") {
          dxc = 8.2%
        }
        place(top, dx: dxc, dy: 10%)[
          #text(size: 2.5em, fill: white)[#type-chapter #counter(heading).display(states.num-heading.get())]
        ]

        place(right, dx: dxb, dy: 22.75%)[
          #box(outset: 0.9em, radius: 5em, stroke: none, fill: states.colors.get().primary)[#text(size: 1.5em, fill: white)[#it.body]]
        ]
        v(15em)
      } else {
        let dxr = 0%
        if states.layout.get().contains("tufte") {
          dxr = 4%
        }
        place(top, dx: -16% + dxr, dy: -11%)[
          #fullwidth[#rect(fill: gradient.linear(states.colors.get().primary, states.colors.get().primary.transparentize(65%), dir: ltr), width: 132% + dxr, height: 10%)]
        ]

        place(top + right, dx: dxb, dy: -2.25%)[
          #box(outset: 0.9em, radius: 5em, stroke: none, fill: states.colors.get().primary)[#text(size: 1.5em, fill: white)[#it.body]]
        ]

        v(3em)
      }
    }
  }

  it
}

#let heading-level2(it) = {
  show heading.where(level: 2): it => if states.theme.get().contains("fancy") {
    block(above: 1.5em)[
      #if it.numbering != none {
        text(counter(heading).display(), fill: states.colors.get().primary)
        h(0.25em)
      }
      #text(it.body)
      #v(-0.5em)
      #line(stroke: 1.5pt + states.colors.get().secondary, length: 100%)
      #v(0.75em)
    ]
  } else if states.theme.get().contains("classic") {
    block(above: 2em, below: 1.25em)[
      #it
    ]
  } else if states.theme.get().contains("modern") {
    block(above: 1.5em)[
      #if it.numbering != none {
        text(counter(heading).display(), fill: states.colors.get().primary)
        h(0.25em)
      }
      #text(it.body)
      #v(-0.75em)
      #line(stroke: 0.75pt + states.colors.get().primary, length: 100%)
      #v(0.75em)
    ]
  }

  it
}

#let heading-level3(it) = {
  show heading.where(level: 3): it => if states.theme.get().contains("fancy") or states.theme.get().contains("modern") {
    block[
      #if it.numbering != none {
        text(counter(heading).display(), fill: states.colors.get().primary)
        h(0.25em)
      }
      #text(it.body)
      #v(1em)
    ]
  } else if states.theme.get().contains("classic") {
    block(above: 1.25em, below: 1.25em)[
      #it
    ]
  }

  it
}

// Outline
#let outline-entry(it) = {
  show outline.entry: it => context {
    let dxl = 0%
    let dxr = 0%
    if states.layout.get().contains("tufte") {
      dxl = 8.17%
      dxr = -17%
    }
    show: move.with(dx: dxl)
    if states.theme.get().contains("fancy") or states.theme.get().contains("modern") {
      if it.element.func() == heading {
        block(below: 0em)
        let number = it.prefix()
        let section = it.element.body
        let item = none
        if it.level == 1 {
          item = fullwidth(dx: dxr)[#text([*#number*], fill: states.colors.get().primary) *#it.inner()*]
        } else if it.level == 2{
          item = fullwidth(dx: dxr)[#h(1em) #text([#number], fill: states.colors.get().primary) #it.inner()]
        } else {
          item = fullwidth(dx: dxr)[#h(2em) #text([#number], fill: states.colors.get().primary) #it.inner()]
        }
        link(it.element.location(), item)
      } else if it.element.func() == figure {
        block(below: 1em)
        link(it.element.location(), fullwidth(dx: dxr)[#text([#it.prefix().], fill: states.colors.get().primary) #h(0.2em) #it.inner()])
      } else {
        it
      }
    } else if states.theme.get().contains("classic") {
      if it.element.func() == heading {
        block(below: 0.5em)
        let number = it.prefix()
        let section = it.element.body
        let item = none
        if it.level == 1 {
          item = [*#number #it.inner()*]
        } else if it.level == 2 {
          item = fullwidth(dx: dxr)[#h(1em) #number #it.inner()]
        } else {
          item = fullwidth(dx: dxr)[#h(2em) #number #it.inner()]
        }
        link(it.element.location(), item)
      } else if it.element.func() == figure {
        block(below: 0.5em)
        link(it.element.location(), fullwidth(dx: dxr)[#text([#it.prefix().], fill: black) #h(0.2em) #it.inner()])
      } else {
        it
      }
    }
  }

  it
}

// Page header and footer - add empty page if necessary
#let page-header = context {
  // let dxl = 0%
  // let dxr = 0%
  // if states.layout.get().contains("tufte") {
    // dxl = 8.17%
    // dxr = -17%
  // }
  // show: move.with(dx: dxl)
  // show: fullwidth.with(dx: dxr)
  show: fullwidth
  if states.theme.get().contains("fancy") {
    set text(style: "italic", fill: states.colors.get().header)
    if calc.odd(here().page()) {
      align(right, hydra(2))
    } else {
      align(left, hydra(1))
    }
  } else if states.theme.get().contains("classic") {
    if calc.odd(here().page()) {
      align(left, hydra(2, display: (_, it) => [
      #let head = none
      #if it.numbering != none {
        head = numbering(it.numbering, ..counter(heading).at(it.location())) + " " + it.body
      } else {
        head = it.body
      }
      #head
      #place(dx: 0%, dy: 50%)[#line(length: 100%, stroke: 0.75pt)]
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
  } else if states.theme.get().contains("modern") {
      set text(style: "italic")
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
            #place(dx: -16%, dy: -40%)[#line(length: 115% - size.width, stroke: 0.5pt + states.colors.get().primary)]
            #place(dx: 98.5% - size.width, dy: -75%)[#circle(fill: states.colors.get().primary, stroke: none, radius: 0.25em)]
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
          #place(dx: size.width + 1%, dy: -40%)[#line(length: 115%, stroke: 0.5pt + states.colors.get().primary)]
          #place(dx: size.width, dy: -75%)[#circle(fill: states.colors.get().primary, stroke: none, radius: 0.25em)]
          ]
        )
      ]
    }
  }
}

#let page-footer = context {
  let cp = counter(page).get().first()
  let current-page = counter(page).display()
  let dx = 0%
  if states.theme.get().contains("modern") {
    show: fullwidth
    set text(fill: white, weight: "bold")
    v(1.5em)
    if calc.odd(cp) {
      // if states.layout.get().contains("tufte") {
      //   dx = 35.15%
      //   // dx = 44%
      // }
      set align(right)
      // move(dx: dx)[
        box(outset: 6pt, fill: states.colors.get().primary, width: 1.5em, height: 100%)[
          #set align(center)
          #current-page
        ]
      // ]
    } else {
      if states.layout.get().contains("tufte") {
        dx = 8.2%
      }
      set align(left)
      // move(dx: dx)[
        box(outset: 6pt, fill: states.colors.get().primary, width: 1.5em, height: 100%)[
          #set align(center)
          #current-page
        ]
      // ]
    }
  } else if states.theme.get().contains("classic") {
    if states.layout.get().contains("tufte") {
      dx = 21.65%
    }
    set align(center)
    move(dx: dx, current-page)
  } else if states.theme.get().contains("fancy") {
    let page-final = counter(page).final().first()
    if states.layout.get().contains("tufte") {
      dx = 21.65%
    }
    set align(center)
    if states.isfrontmatter.get() {
      move(dx: dx)[#current-page]
    } else {
      move(dx: dx)[#current-page/#page-final]
    }
  }
}